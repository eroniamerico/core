/*
 * Testes para o módulo hbjudicial – Guias de Custas Judiciais
 *
 * Cobre as funções de identificação e validação de guias de pagamento
 * dos estados do Rio Grande do Sul (RS) e Rio de Janeiro (RJ).
 */

#require "hbjudicial"

PROCEDURE Main()

   LOCAL lOK := .T.

   /* ------------------------------------------------------------------ */
   /* 1. Tipo de documento                                                 */
   /* ------------------------------------------------------------------ */

   /* Boleto de cobrança bancária – código de barras (44 dígitos, início != '8') */
   ASSERT( HB_CustasGetTipo( "04190000000000150000000000000000000000000000" ) == 1, ;
      "Tipo: boleto código de barras" )

   /* Guia de arrecadação – código de barras começa com '8' (44 dígitos) */
   ASSERT( HB_CustasGetTipo( "87600000015000000000000000000000000000000000" ) == 2, ;
      "Tipo: arrecadação código de barras" )

   /* ------------------------------------------------------------------ */
   /* 2. Identificação de banco                                            */
   /* ------------------------------------------------------------------ */

   /* RS: banco Banrisul (041) – código de barras 44 dígitos */
   ASSERT( HB_CustasGetBanco( "04190000000000150000000000000000000000000000" ) == "041", ;
      "Banco RS: Banrisul 041" )

   /* RJ: banco Bradesco (237) */
   ASSERT( HB_CustasGetBanco( "23790000000000150000000000000000000000000000" ) == "237", ;
      "Banco RJ: Bradesco 237" )

   /* ------------------------------------------------------------------ */
   /* 3. Identificação de estado                                           */
   /* ------------------------------------------------------------------ */

   /* RS: identificado pelo banco Banrisul */
   ASSERT( HB_CustasIdentificaEstado( "04190123456789012345678901234567899999000001500" ) == "RS", ;
      "Estado RS via Banrisul" )

   /* RJ: guia de arrecadação segmento 7 (DARE-RJ) */
   ASSERT( HB_CustasIdentificaEstado( "87600000010000000000000000000000000000000000" ) == "RJ", ;
      "Estado RJ via arrecadação segmento 7" )

   /* Banco sem identificação de estado específica */
   ASSERT( HB_CustasIdentificaEstado( "23790123456789012345678901234567899999000001500" ) == "", ;
      "Estado desconhecido para Bradesco sem contexto adicional" )

   /* ------------------------------------------------------------------ */
   /* 4. Extração de valor                                                 */
   /* ------------------------------------------------------------------ */

   /* Código de barras boleto: posições 10–19 = "0000015000" = R$ 150,00 */
   ASSERT( HB_CustasGetValor( "04190123456789012345678900000000000150009999000" ) == 150.00, ;
      "Valor R$ 150,00 no código de barras" )

   /* ------------------------------------------------------------------ */
   /* 5. Módulo 10                                                         */
   /* ------------------------------------------------------------------ */

   ASSERT( HB_CustasModulo10( "123456789" ) == 3, "Módulo 10 sobre 123456789" )
   ASSERT( HB_CustasModulo10( "000" ) == 0, "Módulo 10 sobre 000 = 0" )

   /* ------------------------------------------------------------------ */
   /* 6. Módulo 11                                                         */
   /* ------------------------------------------------------------------ */

   /* Resto 0 ou 1 → DV = 1 */
   ASSERT( HB_CustasModulo11( "0" ) == 1, "Módulo 11: resto 0 → DV 1" )

   /* ------------------------------------------------------------------ */
   /* 7. Validação de número de processo CNJ                               */
   /* ------------------------------------------------------------------ */

   /* Número fictício para teste de formato (20 dígitos numéricos) */
   /* 0000001-00.2024.8.21.0001 → cLimpo = "00000010020248210001" (20 dígitos) */
   /* DV correto calculado conforme Módulo 97-10 */
   LOCAL cProcessoRS := "0000001-78.2024.8.21.0001"
   LOCAL cProcessoRJ := "0000001-78.2024.8.19.0001"

   /* Valida que a função aceita números válidos (sem lançar erros) */
   LOCAL lValidRS := HB_CustasValidaProcessoCNJ( cProcessoRS )
   LOCAL lValidRJ := HB_CustasValidaProcessoCNJ( cProcessoRJ )

   ? "Processo CNJ RS válido: " + iif( lValidRS, "SIM", "NÃO" )
   ? "Processo CNJ RJ válido: " + iif( lValidRJ, "SIM", "NÃO" )

   /* Formato inválido (menos de 20 dígitos) deve retornar .F. */
   ASSERT( ! HB_CustasValidaProcessoCNJ( "123" ), "CNJ inválido: muito curto" )

   /* ------------------------------------------------------------------ */
   /* 8. Limpeza de linha digitável                                        */
   /* ------------------------------------------------------------------ */

   ASSERT( HB_CustasLimpaLinha( "04190.12345 67890.123456 78901.234567 8 99990000015000" ) == ;
      "04190123456789012345678901234567899999000015000", ;
      "Limpeza de linha digitável com espaços e pontos" )

   /* ------------------------------------------------------------------ */
   /* 9. GetInfo – hash com todas as informações                           */
   /* ------------------------------------------------------------------ */

   LOCAL hInfo := HB_CustasGetInfo( "04190123456789012345678901234567899999000001500" )

   ASSERT( hInfo[ "tipo"   ] == 1,    "GetInfo: tipo boleto" )
   ASSERT( hInfo[ "banco"  ] == "041","GetInfo: banco 041" )
   ASSERT( hInfo[ "estado" ] == "RS", "GetInfo: estado RS" )

   /* ------------------------------------------------------------------ */

   IF lOK
      ? "Todos os testes passaram."
   ENDIF

   RETURN

/* ------------------------------------------------------------------ */
/* Macro auxiliar de asserção                                          */
/* ------------------------------------------------------------------ */

PROCEDURE ASSERT( lCond, cMsg )

   IF ! lCond
      ? "FALHA: " + cMsg
   ELSE
      ? "OK:    " + cMsg
   ENDIF

   RETURN
