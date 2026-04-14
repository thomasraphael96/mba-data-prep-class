-- ============================|Tratamento de Nulos (dummy)|===============================
-- dummy data
INSERT INTO dw.dim_data 
(sk_data, data_completa, 
dia, mes, ano, trimestre, semestre, 
nome_mes, dia_semana, final_semana) 
SELECT -1, DATE '1900-01-01', 1, 1, 1900, 1, 1, 'N/A', 'N/A', FALSE 
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_data WHERE sk_data = -1);

-- dummy produto
INSERT INTO dw.dim_produto 
(sk_produto, id_produto, nome_produto, 
descricao_produto, categoria, valor_unitario, 
data_inicio, data_fim, flag_ativo) 
SELECT -1, -1, 'Produto Não Informado', 'N/A', 'N/A', 0.0, DATE '1900-01-01', NULL, 
TRUE WHERE NOT EXISTS (SELECT 1 FROM dw.dim_produto WHERE sk_produto = -1);

-- dummy cliente
INSERT INTO dw.dim_cliente 
(sk_cliente, chave_hash, id_cliente, 
nome_cliente, cpf, email, 
telefone, municipio, estado, 
data_inicio, data_fim, flag_ativo) 
SELECT -1, md5('dummy_cliente'), -1, 'Cliente Não Informado', '00000000000', 'N/A', 'N/A', 'N/A', 'NA', DATE '1900-01-01', NULL, 
TRUE WHERE NOT EXISTS (SELECT 1 FROM dw.dim_cliente WHERE sk_cliente = -1);

-- dummy promotion
INSERT INTO dw.dim_promocao 
(sk_promocao, id_promocao, nome_promocao, 
tipo_desconto, valor_desconto, data_inicio, data_fim) 
SELECT -1, -1, 'Sem Promoção', 'N/A', 0.0, NULL, NULL 
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_promocao WHERE sk_promocao = -1);

-- dummy pagamento
INSERT INTO dw.dim_pagamento 
(sk_pagamento, tipo_pagamento) 
SELECT -1, 'Não Informado' 
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_pagamento WHERE sk_pagamento = -1);

-- dummy status pedido
INSERT INTO dw.dim_status_pedido 
(sk_status, status_pedido) 
SELECT -1, 'Desconhecido' 
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_status_pedido WHERE sk_status = -1);

-- =========================|Protecao de Integridade dos Dados|============================
CREATE UNIQUE INDEX IF NOT EXISTS rg_dim_cliente_ativo
ON dw.dim_cliente (id_cliente)
WHERE flag_ativo = TRUE;

CREATE UNIQUE INDEX IF NOT EXISTS rg_dim_produto_ativo
ON dw.dim_produto (id_produto)
WHERE flag_ativo = TRUE;

CREATE UNIQUE INDEX IF NOT EXISTS rg_dim_promocao_id
ON dw.dim_promocao (id_promocao);

CREATE UNIQUE INDEX IF NOT EXISTS rg_dim_pagamento_tipo
ON dw.dim_pagamento (tipo_pagamento);

CREATE UNIQUE INDEX IF NOT EXISTS rg_dim_status_pedido
ON dw.dim_status_pedido (status_pedido);

-- =========================|Tabela Dim Cliente|============================
-- DIM CLIENTE - INICIO

BEGIN;
-- Inserir novos dados
INSERT INTO dw.dim_cliente (
    id_cliente, nome, email, cidade,
    chave_hash,
    data_inicio, data_fim, flag_ativo
)
SELECT 
    src.id_cliente,
    src.nome,
    src.email,
    src.cidade,
    md5(concat_ws('|', src.nome, src.email, src.cidade)) AS chave_hash,
    CURRENT_TIMESTAMP, -- data_inicio
    NULL, -- data_fim
    TRUE -- flag_ativo
FROM db.clientes src
LEFT JOIN dw.dim_cliente dimen
    ON dimen.id_cliente = src.id_cliente
WHERE dimen.id_cliente IS NULL;

- detectar dados de clientes alterados pela chave hash
WITH clientes_atualizados AS (
    SELECT 
        src.id_cliente,
        src.nome,
        src.email,
        src.cidade,
        md5(concat_ws('|', src.nome, src.email, src.cidade)) AS novo_hash
    FROM db.tb_clientes src
    JOIN dw.dim_cliente dimen
        ON src.id_cliente = dimen.id_cliente
    WHERE dimen.flag_ativo = TRUE
      AND novo_hash <> dimen.chave_hash
),

-- fechar o cliente que estava ativo
fechar_versao_antiga AS (
    UPDATE dw.dim_cliente dimen
    SET 
        data_fim = CURRENT_TIMESTAMP,
        flag_ativo = FALSE
    FROM clientes_atualizados cli_alt
    WHERE dimen.id_cliente = cli_alt.id_cliente
      AND dimen.flag_ativo = TRUE
    RETURNING dimen.id_cliente
)

-- inserir nova versao com dados atualizados
INSERT INTO dw.dim_cliente (
    id_cliente, nome, email, cidade,
    chave_hash,
    data_inicio, data_fim, flag_ativo
)
SELECT 
    cli_alt.id_cliente,
    cli_alt.nome,
    cli_alt.email,
    cli_alt.cidade,
    cli_alt.novo_hash,
    CURRENT_TIMESTAMP,
    NULL,
    TRUE
FROM clientes_atualizados cli_alt
JOIN fechar_versao_antiga fva
    ON cli_alt.id_cliente = fva.id_cliente;

-- DIM CLIENTE - FINAL
COMMIT;

-- =========================|Tabela Dim Produto|============================
-- DIM PRODUTO - INICIO

BEGIN;
-- Inserir novos dados
INSERT INTO dw.dim_produto (
    id_produto, nome_produto, descricao_produto,
    categoria, valor_unitario, chave_hash,
    data_inicio, data_fim, flag_ativo
)
SELECT 
    src.id_produto,
    src.nome_produto,
    src.descricao_produto,
    src.categoria,
    src.valor_unitario,
    md5(concat_ws('|', src.nome_produto, src.descricao_produto, src.categoria, src.valor_unitario)) AS chave_hash,
    CURRENT_DATE,
    NULL,
    TRUE
FROM db.produtos src
LEFT JOIN dw.dim_produto dimen
    ON dimen.id_produto = src.id_produto
WHERE dimen.id_produto IS NULL;

- detectar dados de produtos alterados pela chave hash
WITH produtos_atualizados AS (
(
    SELECT 
        src.id_produto,
        src.nome_produto,
        src.descricao_produto,
        src.categoria,
        src.valor_unitario,
        md5(concat_ws('|', src.nome_produto, src.descricao_produto, src.categoria, src.valor_unitario)) AS novo_hash
    FROM db.produtos src
    JOIN dw.dim_produto dimen
        ON src.id_produto = dimen.id_produto
    WHERE dimen.flag_ativo = TRUE
      AND novo_hash <> dimen.hash_dados
),

-- fechar o produto que estava ativo
fechar_versao_antiga AS (
    UPDATE dw.dim_produto dimen
    SET 
        data_fim = CURRENT_DATE,
        flag_ativo = FALSE
    FROM produtos_atualizados prod_alt
    WHERE dimen.id_produto = prod_alt.id_produto
      AND dimen.flag_ativo = TRUE
    RETURNING dimen.id_produto
)

-- inserir nova versao com dados atualizados
INSERT INTO dw.dim_produto (
    id_produto, nome_produto, descricao_produto,
    categoria, valor_unitario, chave_hash,
    data_inicio, data_fim, flag_ativo
)
SELECT 
    prod_alt.id_produto,
    prod_alt.nome_produto,
    prod_alt.descricao_produto,
    prod_alt.categoria,
    prod_alt.valor_unitario,
    prod_alt.novo_hash,
    CURRENT_DATE,
    NULL,
    TRUE
FROM produtos_atualizados prod_alt
JOIN fechar_versao_antiga fva
    ON prod_alt.id_produto = fva.id_produto;

-- DIM PRODUTO - FINAL
COMMIT;

-- =========================|Tabela Dim Promocao|============================
-- DIM PROMOCAO - INICIO
BEGIN;

MERGE INTO dw.dim_promocao AS dimen
USING db.promocoes AS src
ON dimen.id_promocao = src.id_promocao

-- sobrescreve apenas se mudou os dados
WHEN MATCHED AND (
    dimen.nome_promocao IS DISTINCT FROM src.nome_promocao OR
    dimen.tipo_desconto IS DISTINCT FROM src.tipo_desconto OR
    dimen.valor_desconto IS DISTINCT FROM src.valor_desconto OR
    dimen.data_inicio IS DISTINCT FROM src.data_inicio OR
    dimen.data_fim IS DISTINCT FROM src.data_fim
) THEN
    UPDATE SET
        nome_promocao = src.nome_promocao,
        tipo_desconto = src.tipo_desconto,
        valor_desconto = src.valor_desconto,
        data_inicio = src.data_inicio,
        data_fim = src.data_fim

-- insere os dados novos
WHEN NOT MATCHED THEN
    INSERT (
        id_promocao,
        nome_promocao,
        tipo_desconto,
        valor_desconto,
        data_inicio,
        data_fim
    )
    VALUES (
        src.id_promocao,
        src.nome_promocao,
        src.tipo_desconto,
        src.valor_desconto,
        src.data_inicio,
        src.data_fim
    );

-- DIM PROMOCAO - FIM
COMMIT;
-- ===========================|Tabela Dim Pagamento|==============================
-- DIM Pagamento - FIM
BEGIN;

MERGE INTO dw.dim_pagamento AS dimen
USING (
    SELECT DISTINCT tipo_pagamento
    FROM db.tb_pagamentos
) AS src
ON dimen.tipo_pagamento = src.tipo_pagamento

WHEN NOT MATCHED THEN
    INSERT (tipo_pagamento)
    VALUES (src.tipo_pagamento);

-- DIM Pagamento - FIM
COMMIT;
-- =========================|Tabela Dim Status Pedido|============================
-- DIM Status - FIM
BEGIN;

MERGE INTO dw.dim_status_pedido AS dimen
USING (
    SELECT DISTINCT status_pedido
    FROM db.tb_pedidos
) AS src
ON dimen.status_pedido = src.status_pedido

WHEN NOT MATCHED THEN
    INSERT (status_pedido)
    VALUES (src.status_pedido);

-- DIM Status - FIM
COMMIT;