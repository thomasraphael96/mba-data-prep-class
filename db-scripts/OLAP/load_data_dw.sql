-- carregamento dos dados da dimensao calendario
INSERT INTO dw.dim_data
SELECT 
    TO_CHAR(datum, 'YYYYMMDD')::INT AS sk_data,
    datum AS data_completa,
    EXTRACT(DAY FROM datum) AS dia,
    EXTRACT(MONTH FROM datum) AS mes,
    EXTRACT(YEAR FROM datum) AS ano,
    TO_CHAR(datum, 'TMMonth') AS nome_mes,
    TO_CHAR(datum, 'TMDay') AS dia_semana,
    EXTRACT(QUARTER FROM datum) AS trimestre,
    CASE WHEN EXTRACT(MONTH FROM datum) <= 6 THEN 1 ELSE 2 END AS semestre,
    CASE WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE ELSE FALSE END AS final_semana
FROM generate_series('1900-01-01'::DATE, '2030-12-31'::DATE, '1 day'::interval) datum;