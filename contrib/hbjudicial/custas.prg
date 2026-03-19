/*
 * Identificação e Validação de Guias de Pagamento de Custas Judiciais
 * por Estado Brasileiro (Rio Grande do Sul e Rio de Janeiro)
 *
 * Copyright 2026 Contributor
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file LICENSE.txt.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA (or visit https://www.gnu.org/licenses/).
 */

/* Referências:
 *   FEBRABAN – Manual de Especificações Técnicas do Boleto de Pagamento
 *   Resolução CNJ nº 65/2008 – Numeração Única de Processos Judiciais
 *   doc/custas_judiciais.md – documentação completa em português
 */

#define HB_CUSTAS_TIPO_BOLETO      1   /* Cobrança bancária padrão FEBRABAN */
#define HB_CUSTAS_TIPO_ARRECADACAO 2   /* Guia de arrecadação (início com '8') */
#define HB_CUSTAS_TIPO_DESCONHECIDO 0

#define HB_CUSTAS_ESTADO_RS "RS"
#define HB_CUSTAS_ESTADO_RJ "RJ"
#define HB_CUSTAS_ESTADO_DESCONHECIDO ""

/* Códigos de banco FEBRABAN relevantes para custas judiciais estaduais */
#define HB_BANCO_BANRISUL  "041"   /* Banco do Estado do Rio Grande do Sul (TJRS) */
#define HB_BANCO_BB        "001"   /* Banco do Brasil */
#define HB_BANCO_CEF       "104"   /* Caixa Econômica Federal */
#define HB_BANCO_BRADESCO  "237"   /* Bradesco */
#define HB_BANCO_ITAU      "341"   /* Itaú Unibanco */

/* Identificador de segmento de arrecadação para guias estaduais de custas */
#define HB_ARRECADACAO_SEGMENTO_OUTROS "7"

/* Código do tribunal no número CNJ */
#define HB_CNJ_TRIBUNAL_TJRS "21"
#define HB_CNJ_TRIBUNAL_TJRJ "19"

/*
 * HB_CustasLimpaLinha( cLinha ) --> cLinhaLimpa
 *
 * Remove espaços, pontos e hífens de uma linha digitável ou código de barras.
 */
FUNCTION HB_CustasLimpaLinha( cLinha )

   LOCAL cResult := ""
   LOCAL i, c

   FOR i := 1 TO Len( cLinha )
      c := SubStr( cLinha, i, 1 )
      IF c >= "0" .AND. c <= "9"
         cResult += c
      ENDIF
   NEXT

   RETURN cResult

/*
 * HB_CustasGetTipo( cLinha ) --> nTipo
 *
 * Identifica o tipo de documento de pagamento:
 *   HB_CUSTAS_TIPO_BOLETO      - boleto de cobrança bancária (44 ou 47 dígitos)
 *   HB_CUSTAS_TIPO_ARRECADACAO - guia de arrecadação governamental (44 ou 48 dígitos)
 *   HB_CUSTAS_TIPO_DESCONHECIDO
 */
FUNCTION HB_CustasGetTipo( cLinha )

   LOCAL cNum := HB_CustasLimpaLinha( cLinha )
   LOCAL nLen := Len( cNum )

   IF nLen == 44
      /* Código de barras: primeiro dígito '8' = arrecadação */
      IF Left( cNum, 1 ) == "8"
         RETURN HB_CUSTAS_TIPO_ARRECADACAO
      ELSE
         RETURN HB_CUSTAS_TIPO_BOLETO
      ENDIF
   ELSEIF nLen == 47
      /* Linha digitável de boleto */
      RETURN HB_CUSTAS_TIPO_BOLETO
   ELSEIF nLen == 48
      /* Linha digitável de arrecadação */
      IF Left( cNum, 1 ) == "8"
         RETURN HB_CUSTAS_TIPO_ARRECADACAO
      ENDIF
   ENDIF

   RETURN HB_CUSTAS_TIPO_DESCONHECIDO

/*
 * HB_CustasGetBanco( cLinha ) --> cCodigoBanco
 *
 * Retorna o código do banco (3 dígitos) de um boleto de cobrança bancária,
 * ou "" se não for aplicável (arrecadação ou formato inválido).
 */
FUNCTION HB_CustasGetBanco( cLinha )

   LOCAL cNum := HB_CustasLimpaLinha( cLinha )
   LOCAL nTipo := HB_CustasGetTipo( cLinha )

   IF nTipo == HB_CUSTAS_TIPO_BOLETO
      IF Len( cNum ) == 47
         /* Linha digitável: banco nos 3 primeiros dígitos */
         RETURN Left( cNum, 3 )
      ELSEIF Len( cNum ) == 44
         /* Código de barras: banco nos 3 primeiros dígitos */
         RETURN Left( cNum, 3 )
      ENDIF
   ENDIF

   RETURN ""

/*
 * HB_CustasGetSegmento( cLinha ) --> cSegmento
 *
 * Para guias de arrecadação, retorna o código do segmento (1 dígito):
 *   "7" = Outros (inclui custas judiciais estaduais)
 *   ""  = não é arrecadação ou formato inválido
 */
FUNCTION HB_CustasGetSegmento( cLinha )

   LOCAL cNum := HB_CustasLimpaLinha( cLinha )

   IF HB_CustasGetTipo( cLinha ) == HB_CUSTAS_TIPO_ARRECADACAO
      IF Len( cNum ) >= 2
         RETURN SubStr( cNum, 2, 1 )
      ENDIF
   ENDIF

   RETURN ""

/*
 * HB_CustasIdentificaEstado( cLinha ) --> cEstado
 *
 * Tenta identificar o estado emissor de uma guia de custas judiciais.
 * Retorna "RS", "RJ", ou "" (desconhecido).
 *
 * Critérios de identificação:
 *   RS: boleto com banco 041 (Banrisul)
 *   RJ: guia de arrecadação com segmento "7" (DARE-RJ) ou boleto com bancos
 *       conveniados ao TJRJ (237, 341, 001, 104) — distinção não é definitiva
 *       só pelo código do banco; use em conjunto com o campo livre.
 */
FUNCTION HB_CustasIdentificaEstado( cLinha )

   LOCAL cBanco   := HB_CustasGetBanco( cLinha )
   LOCAL cSegmento := HB_CustasGetSegmento( cLinha )
   LOCAL nTipo    := HB_CustasGetTipo( cLinha )

   /* RS: identificação pelo banco Banrisul (código exclusivo do estado) */
   IF cBanco == HB_BANCO_BANRISUL
      RETURN HB_CUSTAS_ESTADO_RS
   ENDIF

   /* RJ: guia de arrecadação estadual (DARE-RJ) */
   IF nTipo == HB_CUSTAS_TIPO_ARRECADACAO .AND. cSegmento == HB_ARRECADACAO_SEGMENTO_OUTROS
      RETURN HB_CUSTAS_ESTADO_RJ
   ENDIF

   RETURN HB_CUSTAS_ESTADO_DESCONHECIDO

/*
 * HB_CustasModulo10( cNumeros ) --> nDigito
 *
 * Calcula o dígito verificador pelo algoritmo Módulo 10 (usado nos campos 1, 2 e 3
 * da linha digitável de boletos de cobrança bancária e de arrecadação).
 */
FUNCTION HB_CustasModulo10( cNumeros )

   LOCAL nSoma  := 0
   LOCAL nPeso  := 2
   LOCAL nProd, i, c

   FOR i := Len( cNumeros ) TO 1 STEP -1
      c     := Val( SubStr( cNumeros, i, 1 ) )
      nProd := c * nPeso
      IF nProd > 9
         nProd := nProd - 9
      ENDIF
      nSoma += nProd
      nPeso := iif( nPeso == 2, 1, 2 )
   NEXT

   RETURN ( 10 - ( nSoma % 10 ) ) % 10

/*
 * HB_CustasModulo11( cNumeros ) --> nDigito
 *
 * Calcula o dígito verificador pelo algoritmo Módulo 11 (pesos 2 a 9, cíclicos,
 * da direita para a esquerda). Usado no dígito geral do código de barras.
 * Retorno: 1 quando o resto é 0 ou 1; caso contrário: 11 - resto.
 */
FUNCTION HB_CustasModulo11( cNumeros )

   LOCAL nSoma  := 0
   LOCAL nPeso  := 2
   LOCAL nResto, i

   FOR i := Len( cNumeros ) TO 1 STEP -1
      nSoma += Val( SubStr( cNumeros, i, 1 ) ) * nPeso
      nPeso := iif( nPeso == 9, 2, nPeso + 1 )
   NEXT

   nResto := nSoma % 11
   IF nResto == 0 .OR. nResto == 1
      RETURN 1
   ENDIF

   RETURN 11 - nResto

/*
 * HB_CustasValidaLinhaDigitavel( cLinha ) --> lValido
 *
 * Valida os dígitos verificadores de uma linha digitável de boleto de
 * cobrança bancária (47 dígitos após remoção de formatação).
 *
 * Verifica:
 *   - DV do campo 1 (posição 10) – Módulo 10 sobre posições 1–9
 *   - DV do campo 2 (posição 21) – Módulo 10 sobre posições 11–20
 *   - DV do campo 3 (posição 32) – Módulo 10 sobre posições 22–31
 */
FUNCTION HB_CustasValidaLinhaDigitavel( cLinha )

   LOCAL cNum := HB_CustasLimpaLinha( cLinha )
   LOCAL nDV1, nDV2, nDV3

   IF Len( cNum ) != 47
      RETURN .F.
   ENDIF

   IF HB_CustasGetTipo( cLinha ) != HB_CUSTAS_TIPO_BOLETO
      RETURN .F.
   ENDIF

   /* Campo 1: posições 1–9, DV na posição 10 */
   nDV1 := HB_CustasModulo10( SubStr( cNum, 1, 9 ) )
   IF nDV1 != Val( SubStr( cNum, 10, 1 ) )
      RETURN .F.
   ENDIF

   /* Campo 2: posições 11–20, DV na posição 21 */
   nDV2 := HB_CustasModulo10( SubStr( cNum, 11, 10 ) )
   IF nDV2 != Val( SubStr( cNum, 21, 1 ) )
      RETURN .F.
   ENDIF

   /* Campo 3: posições 22–31, DV na posição 32 */
   nDV3 := HB_CustasModulo10( SubStr( cNum, 22, 10 ) )
   IF nDV3 != Val( SubStr( cNum, 32, 1 ) )
      RETURN .F.
   ENDIF

   RETURN .T.

/*
 * HB_CustasValidaCodigoBarras( cCodigo ) --> lValido
 *
 * Valida o dígito verificador geral de um código de barras de boleto
 * de cobrança bancária (44 dígitos – Módulo 11).
 */
FUNCTION HB_CustasValidaCodigoBarras( cCodigo )

   LOCAL cNum := HB_CustasLimpaLinha( cCodigo )
   LOCAL cSemDV, nDV

   IF Len( cNum ) != 44
      RETURN .F.
   ENDIF

   IF HB_CustasGetTipo( cCodigo ) != HB_CUSTAS_TIPO_BOLETO
      RETURN .F.
   ENDIF

   /* O DV geral está na posição 5; cálculo sobre as demais 43 posições */
   cSemDV := Left( cNum, 4 ) + SubStr( cNum, 6 )
   nDV    := HB_CustasModulo11( cSemDV )

   RETURN nDV == Val( SubStr( cNum, 5, 1 ) )

/*
 * HB_CustasGetValor( cLinha ) --> nValor
 *
 * Extrai o valor em reais de uma linha digitável ou código de barras.
 * Retorna 0.00 se o valor não estiver fixo ou o formato for inválido.
 */
FUNCTION HB_CustasGetValor( cLinha )

   LOCAL cNum  := HB_CustasLimpaLinha( cLinha )
   LOCAL nTipo := HB_CustasGetTipo( cLinha )
   LOCAL cValor

   DO CASE
   CASE nTipo == HB_CUSTAS_TIPO_BOLETO .AND. Len( cNum ) == 44
      /* Código de barras: valor nas posições 10–19 */
      cValor := SubStr( cNum, 10, 10 )
   CASE nTipo == HB_CUSTAS_TIPO_BOLETO .AND. Len( cNum ) == 47
      /* Linha digitável: valor nas posições 38–47 (campo 5, últimos 10 dígitos) */
      cValor := Right( cNum, 10 )
   CASE nTipo == HB_CUSTAS_TIPO_ARRECADACAO .AND. Len( cNum ) == 44
      /* Código de barras arrecadação: valor nas posições 5–14 */
      cValor := SubStr( cNum, 5, 10 )
   CASE nTipo == HB_CUSTAS_TIPO_ARRECADACAO .AND. Len( cNum ) == 48
      /* Linha digitável arrecadação: valor nas posições 34–43 */
      cValor := SubStr( cNum, 34, 10 )
   OTHERWISE
      RETURN 0.00
   ENDCASE

   RETURN Val( cValor ) / 100.0

/*
 * HB_CustasValidaProcessoCNJ( cNumProcesso ) --> lValido
 *
 * Valida o número de processo judicial no formato CNJ:
 *   NNNNNNN-DD.AAAA.J.TT.OOOO
 * Conforme Resolução CNJ nº 65/2008 (algoritmo Módulo 97-10).
 */
FUNCTION HB_CustasValidaProcessoCNJ( cNumProcesso )

   LOCAL cLimpo, cNNNNNNN, cDD, cAAAA, cJ, cTT, cOOOO
   LOCAL nResto
   LOCAL i, c, cDigitos

   /* Remove formatação: traços, pontos */
   cLimpo := ""
   FOR i := 1 TO Len( cNumProcesso )
      c := SubStr( cNumProcesso, i, 1 )
      IF c >= "0" .AND. c <= "9"
         cLimpo += c
      ENDIF
   NEXT

   /* Formato numérico esperado: 20 dígitos (7+2+4+1+2+4) */
   IF Len( cLimpo ) != 20
      RETURN .F.
   ENDIF

   cNNNNNNN := Left( cLimpo, 7 )
   cDD      := SubStr( cLimpo, 8, 2 )
   cAAAA    := SubStr( cLimpo, 10, 4 )
   cJ       := SubStr( cLimpo, 14, 1 )
   cTT      := SubStr( cLimpo, 15, 2 )
   cOOOO    := Right( cLimpo, 4 )

   /* Cálculo Módulo 97-10 conforme CNJ:
    * Concatena NNNNNNN + AAAA + J + TT + OOOO e calcula resto mod 97.
    * DV = 98 - resto  */
   cDigitos := cNNNNNNN + cAAAA + cJ + hb_NToS( Val( cTT ) ) + cOOOO
   nResto   := hb_NumMod97( cDigitos )

   RETURN ( 98 - nResto ) == Val( cDD )

/*
 * hb_NumMod97( cNumero ) --> nResto
 *
 * Calcula o resto da divisão de um número inteiro grande (representado como
 * string) por 97, conforme requerido pelo algoritmo ISO 7064 MOD 97-10.
 */
STATIC FUNCTION hb_NumMod97( cNumero )

   LOCAL nResto := 0
   LOCAL i

   FOR i := 1 TO Len( cNumero )
      nResto := ( nResto * 10 + Val( SubStr( cNumero, i, 1 ) ) ) % 97
   NEXT

   RETURN nResto

/*
 * HB_CustasGetInfo( cLinha ) --> hInfo
 *
 * Retorna um hash com informações extraídas de uma guia de pagamento:
 *   hInfo[ "tipo"    ] --> HB_CUSTAS_TIPO_BOLETO ou HB_CUSTAS_TIPO_ARRECADACAO
 *   hInfo[ "banco"   ] --> código do banco (somente para boleto)
 *   hInfo[ "estado"  ] --> "RS", "RJ" ou "" (desconhecido)
 *   hInfo[ "valor"   ] --> valor em reais (numérico)
 *   hInfo[ "segmento"] --> segmento (somente para arrecadação)
 *   hInfo[ "valido"  ] --> .T. se os dígitos verificadores são válidos
 */
FUNCTION HB_CustasGetInfo( cLinha )

   LOCAL hInfo := { ;
      "tipo"     => HB_CustasGetTipo( cLinha ),    ;
      "banco"    => HB_CustasGetBanco( cLinha ),   ;
      "estado"   => HB_CustasIdentificaEstado( cLinha ), ;
      "valor"    => HB_CustasGetValor( cLinha ),   ;
      "segmento" => HB_CustasGetSegmento( cLinha ), ;
      "valido"   => .F. }

   DO CASE
   CASE hInfo[ "tipo" ] == HB_CUSTAS_TIPO_BOLETO
      IF Len( HB_CustasLimpaLinha( cLinha ) ) == 47
         hInfo[ "valido" ] := HB_CustasValidaLinhaDigitavel( cLinha )
      ELSE
         hInfo[ "valido" ] := HB_CustasValidaCodigoBarras( cLinha )
      ENDIF
   OTHERWISE
      hInfo[ "valido" ] := .T.   /* Arrecadação: DV validado externamente */
   ENDCASE

   RETURN hInfo
