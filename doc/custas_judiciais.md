# Guias de Pagamento de Custas Judiciais no Brasil

## Identificação e Validação por Estado

Este documento descreve como identificar e validar guias de pagamento de custas
judiciais no sistema bancário brasileiro, com prioridade para os estados do Rio
Grande do Sul (RS) e Rio de Janeiro (RJ).

---

## 1. Sistema Bancário Brasileiro – Visão Geral

### 1.1 Tipos de Documentos de Arrecadação

O sistema bancário brasileiro utiliza dois formatos principais para documentos de
cobrança:

| Tipo | Descrição | Identificador |
|------|-----------|---------------|
| **Cobrança bancária** | Boleto emitido por um banco cedente para uma entidade beneficiária | Código do banco nos 3 primeiros dígitos do código de barras |
| **Arrecadação** | Guia para tributos, taxas e contribuições governamentais | Primeiro dígito = `8` na linha digitável/código de barras |

As custas judiciais estaduais podem ser cobradas via **cobrança bancária** ou
**arrecadação**, dependendo do estado e do tribunal.

---

### 1.2 Estrutura do Boleto de Cobrança Bancária (FEBRABAN)

**Código de barras (44 dígitos):**

```
[BBB][M][D][FFFF...][DDDDD][VVVVVVVVVV][CAMPO LIVRE 25 dígitos]
 (1)  (2)(3)  (4)     (5)      (6)              (7)
```

| Campo | Posição | Descrição |
|-------|---------|-----------|
| Código do banco | 1–3 | Identifica o banco cobrador (ver tabela FEBRABAN) |
| Moeda | 4 | `9` = Real (BRL) |
| Dígito verificador geral | 5 | Módulo 11 sobre os demais 43 dígitos |
| Fator de vencimento | 6–9 | Dias após 07/10/1997 (base date) |
| Valor | 10–19 | 10 dígitos, 2 casas decimais; `0000000000` = sem valor fixo |
| Campo livre | 20–44 | 25 dígitos definidos pelo banco/cedente |

**Linha digitável (47 dígitos) – dividida em 3 campos + DV geral + vencimento/valor:**

```
Campo 1 (10): [BBB][M][FFFF.F][D1]
Campo 2 (11): [FFFFF.FFFFF][D2]
Campo 3 (11): [FFFFF.FFFFF][D3]
Campo 4  (1): [DV geral]
Campo 5 (15): [DDDD][VVVVVVVVVV][D5]  (fator de vencimento + valor)
```

---

### 1.3 Estrutura da Guia de Arrecadação (Segmento 7 – Governo)

Para guias governamentais (tributos, taxas, custas), o formato é diferente:

**Código de barras (44 dígitos):**

```
[8][S][V][D][VVVVVVVVVV][CAMPO LIVRE 25 dígitos]
 (1)(2)(3)(4)    (5)              (6)
```

| Campo | Posição | Descrição |
|-------|---------|-----------|
| Identificador | 1 | `8` = produto arrecadação |
| Segmento | 2 | `1`=Prefeitura, `2`=Saneamento, `3`=Energia/Gás, `4`=Telecom, `6`=Multas de trânsito, `7`=Outros (inclui custas judiciais) |
| Valor real | 3 | `6` = valor em reais; `7` = valor de referência |
| Dígito verificador | 4 | Módulo 10 ou Módulo 11 (conforme banco) |
| Valor | 5–14 | 10 dígitos |
| Campo livre | 15–44 | 30 dígitos definidos pela entidade |

**Linha digitável (48 dígitos):**

```
Campo 1 (10): [8][S][V][D][CAMPO LIVRE pts 1–6][D1]
Campo 2 (11): [CAMPO LIVRE pts 7–16][D2]
Campo 3 (11): [CAMPO LIVRE pts 17–26][D3]
Campo 4  (1): [DV geral]
Campo 5 (15): [VVVVVVVVVV][DDDDD]   (valor + vencimento/referência)
```

---

## 2. Estado do Rio Grande do Sul (RS)

### 2.1 Sistema Judicial – TJRS

O **Tribunal de Justiça do Rio Grande do Sul (TJRS)** emite guias de pagamento de
custas através do sistema integrado ao **Banrisul** (Banco do Estado do Rio Grande
do Sul).

| Informação | Valor |
|------------|-------|
| Banco principal | **Banrisul** – código FEBRABAN **041** |
| Portal oficial | <https://www.tjrs.jus.br> |
| Sistema de pagamento | Emissão via portal e-SAJ/PROJUD ou balcão do cartório |
| Denominação da guia | DARF Judicial / GRJ (Guia de Recolhimento Judicial) |

### 2.2 Identificação da Guia do RS

A guia de custas emitida pelo TJRS pode ser identificada pelos seguintes elementos:

1. **Código do banco `041`** nos três primeiros dígitos do código de barras (quando
   emitida via boleto Banrisul).
2. **Campo livre** contém o número do processo no formato CNJ
   (`NNNNNNN-DD.AAAA.J.TT.OOOO`) ou o número de controle interno do tribunal.
3. **CNPJ do cedente** no boleto corresponde ao TJRS; verificar no portal para o
   CNPJ atualizado da Comarca ou Secretaria emissora.
4. **Código do convênio** registrado com o Banrisul para o TJRS.

### 2.3 Exemplo de Linha Digitável do RS (Banrisul / código 041)

```
04190.12345 67890.123456 78901.234567 8 99990000015000
^            ^                        ^
Código 041   Campo livre (processo)   DV geral
```

### 2.4 Validação

- **Dígito verificador do campo 1** – Módulo 10
- **Dígito verificador do campo 2** – Módulo 10
- **Dígito verificador do campo 3** – Módulo 10
- **Dígito verificador geral (posição 5 do código de barras)** – Módulo 11
  (pesos 2–9, cíclicos da direita para a esquerda; resto 0 ou 1 → DV = 1)

---

## 3. Estado do Rio de Janeiro (RJ)

### 3.1 Sistema Judicial – TJRJ

O **Tribunal de Justiça do Rio de Janeiro (TJRJ)** utiliza dois mecanismos
principais de arrecadação de custas:

| Mecanismo | Descrição |
|-----------|-----------|
| **DARE-RJ** | Documento de Arrecadação de Receitas Estaduais — usado para custas estaduais |
| **GRJ/Boleto** | Guia de Recolhimento Judicial emitida via banco conveniado |

| Informação | Valor |
|------------|-------|
| Portal oficial | <https://www.tjrj.jus.br> |
| Bancos conveniados | Bradesco (237), Itaú (341), Banco do Brasil (001), Caixa (104) |
| Sistema de emissão | e-SAJ / portal TJRJ / balcão cartório |

### 3.2 Identificação da Guia do RJ

1. **DARE-RJ** (formato arrecadação – primeiro dígito `8`, segmento `7`):
   - Linha digitável começa com `8` seguido de `7` (segmento "Outros/Estadual").
   - Campo livre contém código de receita estadual específico para custas judiciais.
   - O código de produto no campo livre identifica o tipo de custa (ex.: taxa
     judiciária, emolumento, FUNPERJ).

2. **Boleto bancário conveniado**:
   - Código do banco (posições 1–3) corresponde ao banco conveniado (ex.: `237`
     para Bradesco, `001` para Banco do Brasil).
   - Campo livre contém número do processo CNJ ou código de controle do TJRJ.
   - CNPJ do cedente identifica o TJRJ ou a Comarca emissora.

### 3.3 Exemplo de Linha Digitável do RJ (DARE-RJ)

```
83760.00001 00000.000000 00000.000000 8 00000000015000
^  ^
8=arrecadação
 7=segmento Outros (custas estaduais)
```

### 3.4 Códigos de Receita TJRJ (referência)

| Código | Descrição |
|--------|-----------|
| `0190` | Taxa Judiciária – Atos Extrajudiciais |
| `0191` | Taxa Judiciária – 1ª instância |
| `0192` | Taxa Judiciária – 2ª instância / recurso |
| `0370` | FUNPERJ (Fundo Especial do TJRJ) |

> **Nota:** Os códigos de receita podem ser atualizados. Consultar sempre o portal
> oficial <https://www.tjrj.jus.br/custas>.

---

## 4. Comparativo entre RS e RJ

| Critério | RS (TJRS) | RJ (TJRJ) |
|----------|-----------|-----------|
| Banco principal | Banrisul (041) | Bradesco (237) / múltiplos |
| Formato predominante | Cobrança bancária (boleto) | Arrecadação (DARE) + boleto |
| Identificação rápida | Banco `041` na linha digitável | Início `87` na linha digitável |
| Sistema eletrônico | PROJUD / e-SAJ RS | PJe-TJRJ / e-SAJ RJ |
| CNJ integração | Sim – número do processo no campo livre | Sim – número do processo no campo livre |

---

## 5. Sistema CNJ – Conselho Nacional de Justiça

O CNJ padroniza o número de processo judicial no formato:

```
NNNNNNN-DD.AAAA.J.TT.OOOO
```

| Segmento | Descrição |
|----------|-----------|
| `NNNNNNN` | Número sequencial do processo (7 dígitos) |
| `DD` | Dígitos verificadores (Módulo 97-10) |
| `AAAA` | Ano de distribuição (4 dígitos) |
| `J` | Segmento de justiça (`8` = Justiça Estadual) |
| `TT` | Tribunal (`21` = TJRS, `19` = TJRJ) |
| `OOOO` | Órgão julgador / vara |

### 5.1 Códigos de Tribunal (TT)

| Código | Tribunal |
|--------|----------|
| `21` | TJRS – Rio Grande do Sul |
| `19` | TJRJ – Rio de Janeiro |
| `13` | TJSP – São Paulo |
| `08` | TJMG – Minas Gerais |

---

## 6. Integração com APIs e Portais Disponíveis

### 6.1 Consulta Processual CNJ (DataJud)

O CNJ disponibiliza a API **DataJud** para consulta de dados processuais:

- **Endpoint base:** `https://api-publica.datajud.cnj.jus.br/`
- **Autenticação:** chave de API (solicitar no portal CNJ)
- **Exemplo de uso:**
  ```
  GET /api_publica_tjrs/_search
  Body: { "query": { "match": { "numeroProcesso": "..." } } }
  ```

### 6.2 Portal TJRS

- Consulta processual: <https://www.tjrs.jus.br/novo/consulta-processual/>
- Emissão de guias: sistema e-SAJ / PROJUD (acesso via advogado/parte)

### 6.3 Portal TJRJ

- Consulta processual: <https://www3.tjrj.jus.br/consultaProcessoWebV2/>
- Emissão de guias: <https://www.tjrj.jus.br/web/guest/servicosonline/custas>
- DARE-RJ: <https://www.fazenda.rj.gov.br/sefaz/content/conn/UCMServer/uuid/>

---

## 7. Validação de Autenticidade

### 7.1 Mecanismos de Verificação

| Método | Descrição |
|--------|-----------|
| Dígito verificador do boleto | Cálculo Módulo 10 e Módulo 11 (ver seções 1.2 e 1.3) |
| Consulta ao banco | Via internet banking ou API aberta do banco (onde disponível) |
| Consulta ao portal do tribunal | Verificar se a guia consta no sistema interno do TJRS/TJRJ |
| Código de autenticação bancária | Após pagamento, o comprovante contém NSU/autenticação |

### 7.2 Verificação do Número do Processo CNJ (Módulo 97-10)

Para validar o número do processo no formato CNJ:

```
Resto = (NNNNNNN * 10^2 + AAAA * 10^5 + J * 10^9 + TT * 10^10 + OOOO * 10^12) MOD 97
DV esperado = 98 - Resto
```

Se `DV` calculado coincidir com o `DD` impresso, o número do processo é válido.

---

## 8. Referências

- FEBRABAN – Manual de Especificações Técnicas do Boleto de Pagamento:
  <https://febraban.org.br>
- CNJ – Resolução nº 65/2008 (numeração unificada de processos):
  <https://atos.cnj.jus.br/atos/detalhar/119>
- TJRS – Portal de Custas Judiciais: <https://www.tjrs.jus.br>
- TJRJ – Tabela de Custas: <https://www.tjrj.jus.br>
- Banco Central do Brasil – ISPB/Códigos de bancos:
  <https://www.bcb.gov.br/pom/spb/estatistica/port/ParticipantesSTRport.csv>
