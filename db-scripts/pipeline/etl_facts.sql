-- protecao de integridade dos dados
CREATE UNIQUE INDEX IF NOT EXISTS rg_fato_item_origem
ON dw.fato_vendas (sk_venda);

-- carga da fato
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
    preco_final,
    valor_bruto,
    valor_desconto,
    valor_liquido
)
SELECT
    ip.id_item,

    COALESCE(dd.sk_data, -1),
    COALESCE(dc.sk_cliente, -1),
    COALESCE(dp.sk_produto, -1),
    COALESCE(dpr.sk_promocao, -1),
    COALESCE(dpg.sk_pagamento, -1),
    COALESCE(ds.sk_status, -1),

    ip.num_quantidade,

    ip.vlr_preco_base,

    ip.vlr_preco_final,

    -- valor bruto
    ip.num_quantidade * ip.vlr_preco_base AS valor_bruto,

    -- valor desconto
    (ip.num_quantidade * ip.vlr_preco_base) 
    - (ip.num_quantidade * ip.vlr_preco_final) AS valor_desconto,

    -- valor líquido
    ip.num_quantidade * ip.vlr_preco_final AS valor_liquido

FROM db.tb_itens_pedido ip

JOIN db.tb_pedidos p
    ON p.id_pedido = ip.id_pedido

LEFT JOIN db.tb_pagamento pg
    ON pg.id_pedido = p.id_pedido

-- joins com as dimensoes
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

-- evitar duplicar linhas na fato
WHERE NOT EXISTS (
    SELECT 1
    FROM dw.fato_vendas f
    WHERE f.sk_venda = ip.id_item
);