# README_SQL

## Projeto

**Data Analytics com Dados Abertos da Polícia Rodoviária Federal (PRF)**

Módulo 3 – SQL com DuckDB

---

## Objetivo

Este projeto tem como objetivo explorar e analisar os dados de acidentes da Polícia Rodoviária Federal utilizando SQL no DuckDB.

Durante o desenvolvimento foram realizadas consultas exploratórias, agregações, análises temporais, criação de indicadores e construção de uma variável-alvo para identificar acidentes fatais.

A variável-alvo utilizada foi:

* **acidente_fatal = 1** quando `mortos >= 1`
* **acidente_fatal = 0** quando `mortos = 0`

---

## Fonte dos Dados

Polícia Rodoviária Federal (PRF)

Base de dados públicos de acidentes rodoviários referente ao ano de 2025.

Arquivo utilizado:

```
acidentes2025.csv
```

---

## Ferramentas Utilizadas

* DuckDB
* SQL
* Windows

---

## Estrutura do Projeto

```
Projeto_PRF/
│
├── dados_brutos/
│   └── acidentes2025.csv
│
├── sql/
│   └── modulo3_prf.sql
│
├── resultados/
│   ├── indicadores_mensais.csv
│   ├── indicadores_uf_br.csv
│   ├── bivariada_tipo_acidente.csv
│   ├── base_analitica_sql.csv
│   └── base_modelavel_preliminar_sql.csv
│
└── docs/
    └── README_SQL.md
```

---

## Organização do Script SQL

O arquivo `modulo3_prf.sql` está dividido nas seguintes etapas:

1. Importação da base
2. Validação da importação
3. Consultas exploratórias
4. Criação da variável-alvo e da view base
5. Análise temporal
6. Consultas univariadas
7. Consultas bivariadas
8. Consultas multivariadas
9. Criação das views analíticas
10. Exportação dos resultados
11. Validação final

---

## Views Criadas

* `vw_acidentes_base`
* `vw_indicadores_mensais`
* `vw_indicadores_uf_br`
* `vw_bivariada_tipo_acidente`

---

## Arquivos Gerados

Após a execução do script são gerados os seguintes arquivos CSV:

* `indicadores_mensais.csv`
* `indicadores_uf_br.csv`
* `bivariada_tipo_acidente.csv`
* `base_analitica_sql.csv`
* `base_modelavel_preliminar_sql.csv`

Todos são gravados na pasta:

```
Projeto_PRF/resultados/
```

---

## Como Executar

1. Abrir o DuckDB.
2. Executar o arquivo `modulo3_prf.sql`.
3. Verificar se todas as consultas foram executadas sem erros.
4. Conferir os arquivos gerados na pasta `resultados`.

---

## Validação

Ao final da execução do script são realizadas consultas para validar:

* quantidade total de registros importados;
* quantidade de acidentes fatais;
* percentual global de acidentes fatais;
* existência das views utilizadas na análise.

---

## Observações

Este projeto utiliza os dados exatamente como disponibilizados pela Polícia Rodoviária Federal. Os indicadores produzidos representam análises descritivas da base de dados e não devem ser interpretados como medidas de risco populacional ou causalidade.
