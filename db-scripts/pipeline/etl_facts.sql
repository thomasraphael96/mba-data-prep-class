CREATE UNIQUE INDEX IF NOT EXISTS rg_fato_item_origem
ON dw.fato_vendas (sk_venda);

WITH base AS (
    SELECT
        ip.id_item AS sk_venda,

        COALESCE(dd.sk_data, -1) AS sk_data,
        COALESCE(dc.sk_cliente, -1) AS sk_cliente,
        COALESCE(dp.sk_produto, -1) AS sk_produto,
        COALESCE(dpr.sk_promocao, -1) AS sk_promocao,
        COALESCE(dpg.sk_pagamento, -1) AS sk_pagamento,
        COALESCE(ds.sk_status, -1) AS sk_status,

        COALESCE(ip.num_quantidade, 0) AS quantidade,
        COALESCE(ip.vlr_preco_base, 0) AS preco_base,

        -- valor bruto
        COALESCE(ip.num_quantidade, 0) * COALESCE(ip.vlr_preco_base, 0) AS valor_bruto,

        -- valor desconto
        CASE 
            WHEN dpr.tipo_desconto = 'percentual' THEN 
                COALESCE(ip.num_quantidade, 0) 
                * COALESCE(ip.vlr_preco_base, 0) 
                * (COALESCE(dpr.valor_desconto, 0) / 100.0)

            WHEN dpr.tipo_desconto = 'fixo' THEN 
                COALESCE(ip.num_quantidade, 0) 
                * COALESCE(dpr.valor_desconto, 0)

            ELSE 0
        END AS valor_desconto

    FROM db.tb_itens_pedido ip

    JOIN db.tb_pedidos p
        ON p.id_pedido = ip.id_pedido

    LEFT JOIN db.tb_pagamento pg
        ON pg.id_pedido = p.id_pedido

    -- promoção temporal (1 por item)
    LEFT JOIN LATERAL (
        SELECT pp.id_promocao
        FROM db.tb_promocao_produto pp
        JOIN db.tb_promocao pr
            ON pr.id_promocao = pp.id_promocao
        WHERE pp.id_produto = ip.id_produto
          AND p.dt_pedido >= pr.dt_inicio
          AND (p.dt_pedido <= pr.dt_fim OR pr.dt_fim IS NULL)
        ORDER BY pr.dt_inicio DESC
        LIMIT 1
    ) pp ON TRUE

    -- dimensões
    LEFT JOIN dw.dim_data dd
        ON dd.data_completa = p.dt_pedido

    LEFT JOIN dw.dim_cliente dc
        ON dc.id_cliente = p.id_cliente
       AND p.dt_pedido >= dc.data_inicio
       AND (p.dt_pedido < dc.data_fim OR dc.data_fim IS NULL)

    LEFT JOIN dw.dim_produto dp
        ON dp.id_produto = ip.id_produto
       AND p.dt_pedido >= dp.data_inicio
       AND (p.dt_pedido < dp.data_fim OR dp.data_fim IS NULL)

    LEFT JOIN dw.dim_promocao dpr
        ON dpr.id_promocao = pp.id_promocao

    LEFT JOIN dw.dim_pagamento dpg
        ON dpg.tipo_pagamento = pg.tp_pagamento

    LEFT JOIN dw.dim_status_pedido ds
        ON ds.status_pedido = p.des_status
)

INSERT INTO dw.fato_vendas (
    sk_venda,
    sk_data,
    sk_cliente,
    sk_produto,
    sk_promocao,
    sk_pagamento,
    sk_status,
    quantidade,
    preco_base,
    valor_bruto,
    valor_desconto,
    valor_liquido
)
SELECT
    sk_venda,
    sk_data,
    sk_cliente,
    sk_produto,
    sk_promocao,
    sk_pagamento,
    sk_status,
    quantidade,
    preco_base,
    valor_bruto,
    valor_desconto,

    -- valor líquido correto
    valor_bruto - valor_desconto

FROM base b
WHERE NOT EXISTS (
    SELECT 1
    FROM dw.fato_vendas f
    WHERE f.sk_venda = b.sk_venda
);