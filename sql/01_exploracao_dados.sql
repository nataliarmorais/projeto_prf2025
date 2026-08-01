-- /*
======================================================
Projeto: Acidentes PRF 2025
Módulo: 03 - Exploração Inicial
Banco: DuckDB
======================================================
*/

-- Verificar a versão do DuckDB
SELECT version();

-- Verificar tabelas existentes
SHOW TABLES;

-- Verificar estrutura da tabela
DESCRIBE acidentes_prf_2025;

-- Contar total de registros
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
    condicao_meteorologica,
    tipo_pista,
    tracado_via,
    uso_solo,
    mortos
FROM acidentes_prf_2025
LIMIT 20;

-- Quais UFs existem na base
SELECT DISTINCT uf
FROM acidentes_prf_2025
ORDER BY uf;

-- Quantidade de acidentes por UF
SELECT
    uf,
    COUNT(*) AS total_acidentes
FROM acidentes_prf_2025
GROUP BY uf
ORDER BY total_acidentes DESC;

-- Causas de acidentes mais frequentes
SELECT
    causa_acidente,
    COUNT(*) AS total
FROM acidentes_prf_2025
GROUP BY causa_acidente
ORDER BY total DESC
LIMIT 10;

-- Tipos de acidentes mais frequentes
SELECT
    tipo_acidente,
    COUNT(*) AS total
FROM acidentes_prf_2025
GROUP BY tipo_acidente
ORDER BY total DESC
LIMIT 10;

-- Tipos de acidente com maior número de mortes
SELECT
    tipo_acidente,
    SUM(mortos) AS total_mortos
FROM acidentes_prf_2025
GROUP BY tipo_acidente
ORDER BY total_mortos DESC
LIMIT 10;

-- Total de mortes por dia da semana
SELECT
    dia_semana,
    SUM(mortos) AS total_mortos
FROM acidentes_prf_2025
GROUP BY dia_semana
ORDER BY total_mortos DESC;