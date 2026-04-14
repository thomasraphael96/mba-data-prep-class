-- ============================|Tratamento de Nulos (dummy)|===============================
-- dummy data
INSERT INTO dw.dim_data 
(sk_data, data_completa, 
dia, mes, ano, trimestre, semestre, 
nome_mes, dia_semana, final_semana) 
SELECT -1, DATE '1900-01-01', 1, 1, 1900, 1, 1, 'January', 'Monday', FALSE 
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_data WHERE sk_data = -1);

-- dummy produto
INSERT INTO dw.dim_produto 
(sk_produto, id_produto, nome_produto, 
descricao_produto, categoria, valor_unitario, 
data_inicio, data_fim, flag_ativo) 
SELECT -1, -1, 'Produto Não Informado', 'N/A', 'N/A', 0.0, DATE '1900-01-01', NULL, TRUE
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_produto WHERE sk_produto = -1);

-- dummy cliente
INSERT INTO dw.dim_cliente 
(sk_cliente, chave_hash, id_cliente, 
nome_cliente, cpf, email, 
telefone, municipio, estado, 
data_inicio, data_fim, flag_ativo) 
SELECT -1, md5('dummy_cliente'), -1, 'Cliente Não Informado', '00000000000', 'N/A', 'N/A', 'N/A', 'NA', DATE '1900-01-01', NULL, TRUE 
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_cliente WHERE sk_cliente = -1);

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

INSERT INTO dw.dim_cliente (
    id_cliente,
    nome_cliente,
    cpf,
    email,
    telefone,
    municipio,
    estado,
    chave_hash,
    data_inicio,
    data_fim,
    flag_ativo
)
SELECT 
    src.id_cliente,
    src.des_nome,
    src.num_cpf,
    src.des_email,
    src.num_telefone,
    addr.des_municipio,
    addr.des_estado,
    md5(concat_ws('|', src.des_nome, src.des_email, src.num_telefone, addr.des_estado, addr.des_municipio)),
    src.dt_cadastro,
    NULL,
    TRUE
FROM db.tb_clientes src
LEFT JOIN (
    SELECT DISTINCT ON (id_cliente)
        id_cliente,
        des_municipio,
        des_estado
    FROM db.tb_enderecos
    ORDER BY id_cliente, id_endereco DESC
) addr
    ON src.id_cliente = addr.id_cliente
LEFT JOIN dw.dim_cliente dimen
    ON dimen.id_cliente = src.id_cliente
WHERE dimen.id_cliente IS NULL;

WITH clientes_atualizados AS (
    SELECT 
        src.id_cliente,
        src.des_nome,
        src.num_cpf,
        src.des_email,
        src.num_telefone,
        addr.des_municipio,
        addr.des_estado,
        md5(concat_ws('|', src.des_nome, src.des_email, src.num_telefone, addr.des_estado, addr.des_municipio)) AS novo_hash
    FROM db.tb_clientes src
    LEFT JOIN (
        SELECT DISTINCT ON (id_cliente)
            id_cliente,
            des_municipio,
            des_estado
        FROM db.tb_enderecos
        ORDER BY id_cliente, id_endereco DESC
    ) addr
        ON src.id_cliente = addr.id_cliente
    JOIN dw.dim_cliente dimen
        ON src.id_cliente = dimen.id_cliente
    WHERE dimen.flag_ativo = TRUE
      AND md5(concat_ws('|', src.des_nome, src.des_email, src.num_telefone, addr.des_estado, addr.des_municipio)) <> dimen.chave_hash
),

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

INSERT INTO dw.dim_cliente (
    id_cliente,
    nome_cliente,
    cpf,
    email,
    telefone,
    municipio,
    estado,
    chave_hash,
    data_inicio,
    data_fim,
    flag_ativo
)
SELECT 
    cli_alt.id_cliente,
    cli_alt.des_nome,
    cli_alt.num_cpf,
    cli_alt.des_email,
    cli_alt.num_telefone,
    cli_alt.des_municipio,
    cli_alt.des_estado,
    cli_alt.novo_hash,
    CURRENT_TIMESTAMP,
    NULL,
    TRUE
FROM clientes_atualizados cli_alt
JOIN fechar_versao_antiga fva
    ON cli_alt.id_cliente = fva.id_cliente;

COMMIT;

-- =========================|Tabela Dim Produto|============================
-- DIM PRODUTO - INICIO

BEGIN;

INSERT INTO dw.dim_produto (
    id_produto,
    nome_produto,
    descricao_produto,
    categoria,
    valor_unitario,
    chave_hash,
    data_inicio,
    data_fim,
    flag_ativo
)
SELECT 
    src.id_produto,
    src.des_nome,
    src.des_produto,
    cat.des_categoria,
    src.vlr_unitario,
    md5(concat_ws('|', src.des_nome, src.des_produto, cat.des_categoria, src.vlr_unitario)),
    DATE '1900-01-01',
    NULL,
    TRUE
FROM db.tb_produtos src
LEFT JOIN (
    SELECT DISTINCT ON (id_categoria)
        id_categoria,
        des_categoria
    FROM db.tb_categoria
) cat
    ON src.id_categoria = cat.id_categoria
LEFT JOIN dw.dim_produto dimen
    ON dimen.id_produto = src.id_produto
WHERE dimen.id_produto IS NULL;

WITH produtos_atualizados AS (
    SELECT 
        src.id_produto,
        src.des_nome,
        src.des_produto,
        cat.des_categoria,
        src.vlr_unitario,
        md5(concat_ws('|', src.des_nome, src.des_produto, cat.des_categoria, src.vlr_unitario)) AS novo_hash
    FROM db.tb_produtos src
    LEFT JOIN (
        SELECT DISTINCT ON (id_categoria)
            id_categoria,
            des_categoria
        FROM db.tb_categoria
    ) cat
        ON src.id_categoria = cat.id_categoria
    JOIN dw.dim_produto dimen
        ON src.id_produto = dimen.id_produto
    WHERE dimen.flag_ativo = TRUE
      AND md5(concat_ws('|', src.des_nome, src.des_produto, cat.des_categoria, src.vlr_unitario)) <> dimen.chave_hash
),

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

INSERT INTO dw.dim_produto (
    id_produto,
    nome_produto,
    descricao_produto,
    categoria,
    valor_unitario,
    chave_hash,
    data_inicio,
    data_fim,
    flag_ativo
)
SELECT 
    prod_alt.id_produto,
    prod_alt.des_nome,
    prod_alt.des_produto,
    prod_alt.des_categoria,
    prod_alt.vlr_unitario,
    prod_alt.novo_hash,
    CURRENT_TIMESTAMP,
    NULL,
    TRUE
FROM produtos_atualizados prod_alt
JOIN fechar_versao_antiga fva
    ON prod_alt.id_produto = fva.id_produto;

COMMIT;

-- =========================|Tabela Dim Promocao|============================
-- DIM PROMOCAO - INICIO
BEGIN;

MERGE INTO dw.dim_promocao AS dimen
USING db.tb_promocao AS src
ON dimen.id_promocao = src.id_promocao

-- sobrescreve apenas se mudou os dados
WHEN MATCHED AND (
    dimen.nome_promocao IS DISTINCT FROM src.des_nome OR
    dimen.tipo_desconto IS DISTINCT FROM src.tp_desconto OR
    dimen.valor_desconto IS DISTINCT FROM src.vlr_desconto OR
    dimen.data_inicio IS DISTINCT FROM src.dt_inicio OR
    dimen.data_fim IS DISTINCT FROM src.dt_fim
) THEN
    UPDATE SET
        nome_promocao = src.des_nome,
        tipo_desconto = src.tp_desconto,
        valor_desconto = src.vlr_desconto,
        data_inicio = src.dt_inicio,
        data_fim = src.dt_fim

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
        src.des_nome,
        src.tp_desconto,
        src.vlr_desconto,
        src.dt_inicio,
        src.dt_fim
    );

-- DIM PROMOCAO - FIM
COMMIT;
-- ===========================|Tabela Dim Pagamento|==============================
-- DIM Pagamento - FIM
BEGIN;

MERGE INTO dw.dim_pagamento AS dimen
USING (
    SELECT DISTINCT tp_pagamento
    FROM db.tb_pagamento
) AS src
ON dimen.tipo_pagamento = src.tp_pagamento

WHEN NOT MATCHED THEN
    INSERT (tipo_pagamento)
    VALUES (src.tp_pagamento);

-- DIM Pagamento - FIM
COMMIT;
-- =========================|Tabela Dim Status Pedido|============================
-- DIM Status - FIM
BEGIN;

MERGE INTO dw.dim_status_pedido AS dimen
USING (
    SELECT DISTINCT des_status
    FROM db.tb_pedidos
) AS src
ON dimen.status_pedido = src.des_status

WHEN NOT MATCHED THEN
    INSERT (status_pedido)
    VALUES (src.des_status);

-- DIM Status - FIM
COMMIT;