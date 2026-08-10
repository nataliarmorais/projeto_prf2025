-- ======================================================
-- Projeto: Acidentes PRF 2025
-- Módulo: 03 - Exploração Inicial
-- Banco: DuckDB
-- ======================================================

-- Verificar a versão do DuckDB
SELECT version();
-- Verificar tabelas existentes
SHOW TABLES;

-- Verificar estrutura da tabela
DESCRIBE acidentes_prf_2025;

-- Consultar os metadados da tabela
-- Exibe o nome das colunas e seus respectivos tipos de dados.

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'acidentes_prf_2025'
ORDER BY ordinal_position;

-- Ler o arquivo CSV diretamente

SELECT *
FROM read_csv_auto(
    'dados_brutos/acidentes2025.csv',
    delim=';',
    header=true,
    sample_size=-1,
    encoding='latin-1'
)
LIMIT 10;

-- Criar a tabela

CREATE OR REPLACE TABLE acidentes_prf_2025 AS
SELECT *
FROM read_csv_auto(
    'dados_brutos/acidentes2025.csv',
    delim=';',
    header=true,
    sample_size=-1,
    encoding='latin-1'
);

-- Contar o total de registros da tabela

SELECT COUNT(*) AS total_ocorrencias
FROM acidentes_prf_2025;

-- Visualizar as primeiras ocorrências da base

SELECT
    data_inversa,
    dia_semana,
    horario,
    uf,
    br,
    municipio,
    causa_acidente,
    tipo_acidente,
    fase_dia,
    condicao_metereologica,
    tipo_pista,
    tracado_via,
    uso_solo,
    mortos
FROM acidentes_prf_2025
LIMIT 20;

-- ======================================================
-- Ordenar e limitar resultados
-- ORDER BY organiza a leitura dos dados.
-- LIMIT evita retornar um número muito grande de registros.
-- ======================================================

SELECT
    data_inversa,
    uf,
    br,
    municipio,
    causa_acidente,
    tipo_acidente,
    mortos
FROM acidentes_prf_2025
ORDER BY mortos DESC, data_inversa
LIMIT 20;

-- ======================================================
-- Filtrar por UF
-- Exibe os acidentes registrados no estado de Pernambuco (PE).
-- ======================================================

SELECT
    data_inversa,
    uf,
    br,
    municipio,
    mortos,
    causa_acidente
FROM acidentes_prf_2025
WHERE uf = 'PE'
ORDER BY data_inversa
LIMIT 50;

-- ======================================================
-- Filtrar acidentes com mortos
-- Exibe apenas ocorrências com pelo menos uma vítima fatal.
-- ======================================================

SELECT
    data_inversa,
    uf,
    br,
    municipio,
    causa_acidente,
    tipo_acidente,
    mortos
FROM acidentes_prf_2025
WHERE mortos >= 1
ORDER BY mortos DESC
LIMIT 50;

-- ======================================================
-- Listar as fases do dia existentes na base
-- DISTINCT retorna apenas valores únicos.
-- ======================================================

SELECT DISTINCT
    fase_dia
FROM acidentes_prf_2025
ORDER BY fase_dia;

-- ======================================================
-- Listar os tipos de pista existentes na base
-- ======================================================

SELECT DISTINCT
    tipo_pista
FROM acidentes_prf_2025
ORDER BY tipo_pista;

-- ======================================================
-- Quantidade de acidentes por UF
-- GROUP BY agrupa os registros por estado.
-- ======================================================

SELECT
    uf,
    COUNT(*) AS total_acidentes
FROM acidentes_prf_2025
GROUP BY uf
ORDER BY total_acidentes DESC;

-- ======================================================
-- Total de mortes por BR
-- Soma o número de mortos em cada rodovia.
-- ======================================================

SELECT
    br,
    COUNT(*) AS total_acidentes,
    SUM(CAST(mortos AS INTEGER)) AS total_mortos
FROM acidentes_prf_2025
WHERE br IS NOT NULL
GROUP BY br
ORDER BY total_mortos DESC
LIMIT 20;

-- ======================================================
-- Estatísticas gerais da base
-- Funções de agregação: COUNT, SUM, AVG, MIN e MAX.
-- ======================================================

SELECT
    COUNT(*) AS total_acidentes,
    SUM(CAST(mortos AS INTEGER)) AS total_mortos,
    AVG(CAST(mortos AS DOUBLE)) AS media_mortos,
    MIN(CAST(mortos AS INTEGER)) AS menor_qtd_mortos,
    MAX(CAST(mortos AS INTEGER)) AS maior_qtd_mortos
FROM acidentes_prf_2025;

-- ======================================================
-- Criar a variável acidente_fatal
-- Acidentes com um ou mais mortos recebem valor 1.
-- Acidentes sem mortos recebem valor 0.
-- ======================================================

SELECT
    data_inversa,
    uf,
    br,
    municipio,
    mortos,
    CASE
        WHEN CAST(mortos AS INTEGER) >= 1 THEN 1
        ELSE 0
    END AS acidente_fatal
FROM acidentes_prf_2025
LIMIT 30;

-- ======================================================
-- Criar a View Base com a variável acidente_fatal
-- A View facilita consultas futuras sem repetir o CASE.
-- ======================================================

CREATE OR REPLACE VIEW vw_acidentes_base AS

SELECT
    *,
    CASE
        WHEN CAST(mortos AS INTEGER) >= 1 THEN 1
        ELSE 0
    END AS acidente_fatal
FROM acidentes_prf_2025;

SHOW TABLES;

-- ======================================================
-- Taxa Global de Fatalidade
-- Calcula a proporção de acidentes fatais na base.
-- ======================================================

SELECT
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base;

-- ======================================================
-- Extrair o ano e o mês da data do acidente
-- Utiliza a função EXTRACT para obter informações temporais.
-- ======================================================

SELECT
    data_inversa,
    EXTRACT(YEAR FROM CAST(data_inversa AS DATE)) AS ano,
    EXTRACT(MONTH FROM CAST(data_inversa AS DATE)) AS mes
FROM vw_acidentes_base
LIMIT 20;

-- ======================================================
-- Série temporal de acidentes fatais por mês
-- Agrupa os acidentes por mês e calcula o percentual
-- de acidentes fatais.
-- ======================================================

SELECT
    EXTRACT(MONTH FROM CAST(data_inversa AS DATE)) AS mes,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY mes
ORDER BY mes;

-- ======================================================
-- Análise por fase do dia
-- Calcula o total de acidentes, acidentes fatais
-- e o percentual de fatalidade por fase do dia.
-- ======================================================

SELECT
    fase_dia,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY fase_dia
ORDER BY perc_fatais DESC;

-- ======================================================
-- Análise por condição meteorológica
-- Calcula o total de acidentes, acidentes fatais
-- e o percentual de fatalidade por condição climática.
-- ======================================================

SELECT
    condicao_metereologica,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY condicao_metereologica
ORDER BY perc_fatais DESC,
         total_acidentes DESC;

-- ======================================================
-- Análise por condição meteorológica com HAVING
-- Exibe apenas categorias com pelo menos 100 acidentes.
-- ======================================================

SELECT
    condicao_metereologica,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY condicao_metereologica
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- ======================================================
-- Tipo de Acidente x Acidente Fatal
-- Analisa o percentual de acidentes fatais por tipo de acidente.
-- ======================================================

SELECT
    tipo_acidente,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY tipo_acidente
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- ======================================================
-- Causa do Acidente x Acidente Fatal
-- Analisa o percentual de acidentes fatais por causa do acidente.
-- ======================================================

SELECT
    causa_acidente,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY causa_acidente
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC
LIMIT 20;

-- ======================================================
-- Tipo de Pista x Acidente Fatal
-- Analisa o percentual de acidentes fatais por tipo de pista.
-- ======================================================

SELECT
    tipo_pista,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY tipo_pista
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- ======================================================
-- UF x Acidente Fatal
-- Analisa o percentual de acidentes fatais por estado.
-- ======================================================

SELECT
    uf,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY uf
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- ======================================================
-- Consulta por Município
-- Analisa acidentes, mortes e percentual de fatalidade
-- por município.
-- ======================================================

SELECT
    uf,
    municipio,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    SUM(CAST(mortos AS INTEGER)) AS total_mortos,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY
    uf,
    municipio
HAVING COUNT(*) >= 50
ORDER BY total_mortos DESC
LIMIT 30;

-- ======================================================
-- Análise Multivariada
-- Tipo de Pista + Fase do Dia
-- ======================================================

SELECT
    tipo_pista,
    fase_dia,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS cobertura_perc,
    ROUND(
        100.0 * SUM(acidente_fatal) /
        COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY
    tipo_pista,
    fase_dia
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- ======================================================
-- Causa do Acidente + Tipo de Acidente
-- ======================================================

SELECT
    causa_acidente,
    tipo_acidente,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS cobertura_perc,
    ROUND(
        100.0 * SUM(acidente_fatal) /
        COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY
    causa_acidente,
    tipo_acidente
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC
LIMIT 30;

-- ======================================================
-- Introdução ao Lift em SQL
-- Compara a taxa de fatalidade de cada tipo de acidente
-- com a taxa global da base.
-- ======================================================

WITH global AS (
    SELECT
        1.0 * SUM(acidente_fatal) / COUNT(*) AS taxa_global
    FROM vw_acidentes_base
)

SELECT
    tipo_acidente,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        1.0 * SUM(acidente_fatal) / COUNT(*),
        4
    ) AS confianca,
    ROUND(
        (1.0 * SUM(acidente_fatal) / COUNT(*))
        / taxa_global,
        2
    ) AS lift
FROM vw_acidentes_base, global
GROUP BY
    tipo_acidente,
    taxa_global
HAVING COUNT(*) >= 100
ORDER BY lift DESC;

-- ======================================================
-- Indicadores Finais por Categoria com Lift
-- Calcula indicadores por tipo de acidente.
-- ======================================================

WITH global AS (
    SELECT
        1.0 * SUM(acidente_fatal) / COUNT(*) AS taxa_global
    FROM vw_acidentes_base
)

SELECT
    tipo_acidente AS categoria,
    COUNT(*) AS total_acidentes,
    SUM(CAST(mortos AS INTEGER)) AS total_mortos,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais,
    ROUND(
        (1.0 * SUM(acidente_fatal) / COUNT(*))
        / taxa_global,
        2
    ) AS lift
FROM vw_acidentes_base, global
GROUP BY
    categoria,
    taxa_global
HAVING COUNT(*) >= 100
ORDER BY lift DESC;

-- ======================================================
-- Criar View Mensal para Dashboard
-- Consolida indicadores mensais para uso no Power BI.
-- ======================================================

CREATE OR REPLACE VIEW vw_indicadores_mensais AS

SELECT
    EXTRACT(YEAR FROM CAST(data_inversa AS DATE)) AS ano,
    EXTRACT(MONTH FROM CAST(data_inversa AS DATE)) AS mes,
    COUNT(*) AS total_acidentes,
    SUM(CAST(mortos AS INTEGER)) AS total_mortos,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY
    ano,
    mes
ORDER BY
    ano,
    mes;

-- ======================================================
-- Criar View por UF e BR
-- Consolida indicadores por estado e rodovia.
-- ======================================================

CREATE OR REPLACE VIEW vw_indicadores_uf_br AS

SELECT
    uf,
    br,
    COUNT(*) AS total_acidentes,
    SUM(CAST(mortos AS INTEGER)) AS total_mortos,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
WHERE br IS NOT NULL
GROUP BY
    uf,
    br;

-- ======================================================
-- Criar View Bivariada por Tipo de Acidente
-- Calcula indicadores e Lift por tipo de acidente.
-- ======================================================

CREATE OR REPLACE VIEW vw_bivariada_tipo_acidente AS

WITH global AS (
    SELECT
        1.0 * SUM(acidente_fatal) / COUNT(*) AS taxa_global
    FROM vw_acidentes_base
)

SELECT
    tipo_acidente AS categoria,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS cobertura_perc,
    ROUND(
        100.0 * SUM(acidente_fatal) /
        COUNT(*),
        2
    ) AS perc_fatais,
    ROUND(
        (1.0 * SUM(acidente_fatal) / COUNT(*))
        / taxa_global,
        2
    ) AS lift
FROM vw_acidentes_base, global
GROUP BY
    categoria,
    taxa_global
HAVING COUNT(*) >= 100;

-- ======================================================
-- Exportar os indicadores mensais para CSV
-- O arquivo será salvo na pasta resultados.
-- ======================================================

COPY vw_indicadores_mensais
TO 'resultados/indicadores_mensais.csv'
(HEADER, DELIMITER ';');


-- ======================================================
-- Exportar os indicadores por UF e BR
-- ======================================================

COPY vw_indicadores_uf_br
TO 'resultados/indicadores_uf_br.csv'
(HEADER, DELIMITER ';');

-- ======================================================
-- Exportar a análise bivariada por tipo de acidente
-- ======================================================

COPY vw_bivariada_tipo_acidente
TO 'resultados/bivariada_tipo_acidente.csv'
(HEADER, DELIMITER ';');


-- ======================================================
-- Exportar Base Analítica Completa
-- Utilizada para análises descritivas
-- ======================================================

COPY (
    SELECT
        data_inversa,
        dia_semana,
        horario,
        uf,
        br,
        municipio,
        causa_acidente,
        tipo_acidente,
        classificacao_acidente,
        fase_dia,
        condicao_metereologica,
        tipo_pista,
        tracado_via,
        uso_solo,
        mortos,
        acidente_fatal
    FROM vw_acidentes_base
)
TO 'resultados/base_analitica_sql.csv'
(HEADER, DELIMITER ';');

-- ======================================================
-- Exportar Base Modelável Preliminar
-- ======================================================

COPY (
    SELECT
        uf,
        br,
        municipio,
        EXTRACT(MONTH FROM CAST(data_inversa AS DATE)) AS mes,
        dia_semana,
        fase_dia,
        causa_acidente,
        tipo_acidente,
        condicao_metereologica,
        tipo_pista,
        tracado_via,
        uso_solo,
        acidente_fatal
    FROM vw_acidentes_base
)
TO 'resultados/base_modelavel_preliminar_sql.csv'
(HEADER, DELIMITER ';');

-- ======================================================
-- Checagem de valores nulos
-- Quantifica campos nulos na base.
-- ======================================================

SELECT
    SUM(CASE WHEN uf IS NULL
        THEN 1 ELSE 0 END) AS nulos_uf,

    SUM(CASE WHEN br IS NULL
        THEN 1 ELSE 0 END) AS nulos_br,

    SUM(CASE WHEN municipio IS NULL
        THEN 1 ELSE 0 END) AS nulos_municipio,

    SUM(CASE WHEN causa_acidente IS NULL
        THEN 1 ELSE 0 END) AS nulos_causa,

    SUM(CASE WHEN tipo_acidente IS NULL
        THEN 1 ELSE 0 END) AS nulos_tipo

FROM vw_acidentes_base;

-- ======================================================
-- Padronização com COALESCE
-- Substitui valores nulos apenas na consulta.
-- ======================================================

SELECT
    COALESCE(uf, 'NAO_INFORMADO') AS uf_tratada,

    COALESCE(CAST(br AS VARCHAR),
        'NAO_INFORMADO') AS br_tratada,

    COUNT(*) AS total_acidentes

FROM vw_acidentes_base

GROUP BY
    uf_tratada,
    br_tratada

ORDER BY total_acidentes DESC

LIMIT 30;

-- ======================================================
-- Validação Cruzada de Totais
-- Compara o total da base com a soma por UF.
-- ======================================================

SELECT
    'base' AS origem,
    COUNT(*) AS total,
    SUM(acidente_fatal) AS fatais
FROM vw_acidentes_base

UNION ALL

SELECT
    'soma_por_uf' AS origem,
    SUM(total_acidentes),
    SUM(acidentes_fatais)
FROM (

    SELECT
        uf,
        COUNT(*) AS total_acidentes,
        SUM(acidente_fatal) AS acidentes_fatais
    FROM vw_acidentes_base
    GROUP BY uf

);

    

