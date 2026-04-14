-- ============================================================
-- População da dimensão de datas usando generate_series
-- ============================================================
INSERT INTO dw.dim_data (
    sk_data,
    data_completa,
    dia,
    mes,
    ano,
    trimestre,
    semestre,
    nome_mes,
    dia_semana,
    final_semana
)
SELECT 
    TO_CHAR(datum, 'YYYYMMDD')::INT,
    datum,
    EXTRACT(DAY FROM datum),
    EXTRACT(MONTH FROM datum),
    EXTRACT(YEAR FROM datum),
    EXTRACT(QUARTER FROM datum),
    CASE WHEN EXTRACT(MONTH FROM datum) <= 6 THEN 1 ELSE 2 END,
    TO_CHAR(datum, 'TMMonth'),
    TO_CHAR(datum, 'TMDay'),
    CASE WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE ELSE FALSE END
FROM generate_series('1900-01-01'::DATE, '2030-12-31'::DATE, '1 day') datum
WHERE NOT EXISTS (
    SELECT 1 
    FROM dw.dim_data d
    WHERE d.data_completa = datum
);