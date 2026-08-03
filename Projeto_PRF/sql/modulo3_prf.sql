-- =====================================================
-- Módulo 3 - SQL com DuckDB
-- Projeto: Data Analytics com Dados Abertos da PRF
-- Base: Acidentes 2025 agrupados por ocorrência
-- Ferramenta: DuckDB
-- Fonte: Dados Abertos da Polícia Rodoviária Federal
--
-- Objetivo:
-- Identificar fatores associados a acidentes fatais.
--
-- Variável-alvo:
-- acidente_fatal = 1 quando mortos >= 1
-- acidente_fatal = 0 caso contrário
--
-- Autor: Caio Vital
-- Data: 27/07/2026
-- =====================================================

-- =====================================================
-- 1. IMPORTAÇÃO DA BASE
-- =====================================================

CREATE OR REPLACE TABLE acidentes_prf_2025 AS
SELECT *
FROM read_csv_auto(
    'C:/Users/Aluno/Documents/Caio Vital/Projeto_PRF/dados_brutos/acidentes2025.csv.csv',
    delim=';',
    header=true,
    sample_size=-1,
    encoding='latin-1'
);

-- =====================================================
-- 2. VALIDAÇÃO DA IMPORTAÇÃO
-- =====================================================

-- Conferir as tabelas criadas
SHOW TABLES;

-- Conferir estrutura da tabela
DESCRIBE acidentes_prf_2025;

-- Número total de ocorrências
SELECT COUNT(*) AS total_ocorrencias
FROM acidentes_prf_2025;

-- =====================================================
-- 3. CONSULTAS EXPLORATÓRIAS
-- =====================================================

-- Visualizar as principais colunas

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

-- Acidentes com maior número de mortos

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

-- Acidentes ocorridos em Pernambuco

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

-- Acidentes com pelo menos uma vítima fatal

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

-- Categorias de fase do dia

SELECT DISTINCT fase_dia
FROM acidentes_prf_2025
ORDER BY fase_dia;

-- Categorias de tipo de pista

SELECT DISTINCT tipo_pista
FROM acidentes_prf_2025
ORDER BY tipo_pista;

-- Acidentes por UF

SELECT
    uf,
    COUNT(*) AS total_acidentes
FROM acidentes_prf_2025
GROUP BY uf
ORDER BY total_acidentes DESC;

-- Mortes por BR

SELECT
    br,
    COUNT(*) AS total_acidentes,
    SUM(mortos) AS total_mortos
FROM acidentes_prf_2025
WHERE br IS NOT NULL
GROUP BY br
ORDER BY total_mortos DESC
LIMIT 20;

-- Estatísticas gerais

SELECT
    COUNT(*) AS total_ocorrencias,
    SUM(mortos) AS total_mortos,
    AVG(mortos) AS media_mortos_por_ocorrencia,
    MIN(mortos) AS min_mortos,
    MAX(mortos) AS max_mortos
FROM acidentes_prf_2025;

-- =====================================================
-- 4. VARIÁVEL-ALVO E VIEW BASE
-- =====================================================

-- Visualizar a criação da variável-alvo

SELECT
    data_inversa,
    uf,
    br,
    municipio,
    mortos,
    CASE
        WHEN mortos >= 1 THEN 1
        ELSE 0
    END AS acidente_fatal
FROM acidentes_prf_2025
LIMIT 30;

-- Criar a view principal utilizada nas análises

CREATE OR REPLACE VIEW vw_acidentes_base AS
SELECT
    *,
    CASE
        WHEN mortos >= 1 THEN 1
        ELSE 0
    END AS acidente_fatal
FROM acidentes_prf_2025;

-- Conferir a view criada

SELECT *
FROM vw_acidentes_base
LIMIT 10;

-- Taxa global de acidentes fatais

SELECT
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base;

-- =====================================================
-- 5. ANÁLISE TEMPORAL
-- =====================================================

-- Extrair ano e mês

SELECT
    data_inversa,
    EXTRACT(YEAR FROM data_inversa) AS ano,
    EXTRACT(MONTH FROM data_inversa) AS mes
FROM vw_acidentes_base
LIMIT 20;

-- Acidentes fatais por mês

SELECT
    EXTRACT(MONTH FROM data_inversa) AS mes,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY mes
ORDER BY mes;

-- =====================================================
-- 6. CONSULTAS UNIVARIADAS
-- =====================================================

-- Fase do dia

SELECT
    fase_dia,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY fase_dia
ORDER BY perc_fatais DESC;

-- Condição meteorológica

SELECT
    condicao_metereologica,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY condicao_metereologica
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- Tipo de acidente

SELECT
    tipo_acidente,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY tipo_acidente
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- Causa do acidente

SELECT
    causa_acidente,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY causa_acidente
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC
LIMIT 20;

-- Tipo de pista

SELECT
    tipo_pista,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY tipo_pista
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- UF

SELECT
    uf,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY uf
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- =====================================================
-- 7. CONSULTAS BIVARIADAS
-- =====================================================

-- Tipo de acidente

SELECT
    tipo_acidente,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY tipo_acidente
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC, total_acidentes DESC;

-- Causa do acidente

SELECT
    causa_acidente,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY causa_acidente
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC, total_acidentes DESC;

-- Tipo de pista

SELECT
    tipo_pista,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY tipo_pista
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC, total_acidentes DESC;

-- Fase do dia

SELECT
    fase_dia,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY fase_dia
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC, total_acidentes DESC;

-- Condição meteorológica

SELECT
    condicao_metereologica,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY condicao_metereologica
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC, total_acidentes DESC;

-- =====================================================
-- 8. CONSULTAS MULTIVARIADAS
-- =====================================================

-- Tipo de pista x Fase do dia

SELECT
    tipo_pista,
    fase_dia,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY
    tipo_pista,
    fase_dia
HAVING COUNT(*) >= 30
ORDER BY
    perc_fatais DESC,
    total_acidentes DESC;

-- Causa do acidente x Tipo de acidente

SELECT
    causa_acidente,
    tipo_acidente,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY
    causa_acidente,
    tipo_acidente
HAVING COUNT(*) >= 30
ORDER BY
    perc_fatais DESC,
    total_acidentes DESC;

-- =====================================================
-- 9. VIEWS ANALÍTICAS
-- =====================================================

-- View de indicadores mensais

CREATE OR REPLACE VIEW vw_indicadores_mensais AS
SELECT
    EXTRACT(YEAR FROM data_inversa) AS ano,
    EXTRACT(MONTH FROM data_inversa) AS mes,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    SUM(mortos) AS total_mortos,
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

-- View de indicadores por UF e BR

CREATE OR REPLACE VIEW vw_indicadores_uf_br AS
SELECT
    uf,
    br,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    SUM(mortos) AS total_mortos,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY
    uf,
    br;

-- View bivariada por tipo de acidente

CREATE OR REPLACE VIEW vw_bivariada_tipo_acidente AS
SELECT
    tipo_acidente,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base
GROUP BY
    tipo_acidente
HAVING COUNT(*) >= 100
ORDER BY
    perc_fatais DESC,
    total_acidentes DESC;

-- Conferir as views criadas

SHOW TABLES;

-- =====================================================
-- 10. EXPORTAÇÃO DOS RESULTADOS
-- =====================================================

-- Indicadores mensais

COPY (
    SELECT *
    FROM vw_indicadores_mensais
)
TO 'C:/Users/Aluno/Documents/Caio Vital/Projeto_PRF/resultados/indicadores_mensais.csv'
WITH (
    HEADER,
    DELIMITER ','
);

-- Indicadores por UF e BR

COPY (
    SELECT *
    FROM vw_indicadores_uf_br
)
TO 'C:/Users/Aluno/Documents/Caio Vital/Projeto_PRF/resultados/indicadores_uf_br.csv'
WITH (
    HEADER,
    DELIMITER ','
);

-- Indicadores por tipo de acidente

COPY (
    SELECT *
    FROM vw_bivariada_tipo_acidente
)
TO 'C:/Users/Aluno/Documents/Caio Vital/Projeto_PRF/resultados/bivariada_tipo_acidente.csv'
WITH (
    HEADER,
    DELIMITER ','
);

-- Base analítica

COPY (
    SELECT *
    FROM vw_acidentes_base
)
TO 'C:/Users/Aluno/Documents/Caio Vital/Projeto_PRF/resultados/base_analitica_sql.csv'
WITH (
    HEADER,
    DELIMITER ','
);

-- Base modelável preliminar

COPY (
    SELECT
        data_inversa,
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
        mortos,
        acidente_fatal
    FROM vw_acidentes_base
)
TO 'C:/Users/Aluno/Documents/Caio Vital/Projeto_PRF/resultados/base_modelavel_preliminar_sql.csv'
WITH (
    HEADER,
    DELIMITER ','
);

-- =====================================================
-- 11. VALIDAÇÃO FINAL
-- =====================================================

-- Conferir total de registros

SELECT COUNT(*) AS total_registros
FROM acidentes_prf_2025;

-- Conferir total de acidentes fatais

SELECT
    SUM(acidente_fatal) AS acidentes_fatais
FROM vw_acidentes_base;

-- Conferir percentual global de fatalidade

SELECT
    ROUND(
        100.0 * SUM(acidente_fatal) / COUNT(*),
        2
    ) AS perc_fatais
FROM vw_acidentes_base;

-- Conferir as views criadas

SHOW TABLES;

-- =====================================================
-- FIM DO SCRIPT
-- Projeto executado com sucesso.
-- =====================================================
