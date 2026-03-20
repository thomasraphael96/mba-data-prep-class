-- ================|Tabelas independentes (sem FK)|==================
INSERT INTO db.tb_categoria (id_categoria, des_categoria)
SELECT i, 'Categoria ' || i
FROM generate_series(1,10) i;

INSERT INTO db.tb_tipo_customizacao (id_tipo_customizacao, nome)
SELECT i, 'Tipo ' || i
FROM generate_series(1,10) i;

INSERT INTO db.tb_estoque (id_componente, des_componente, tp_componente, qtd_estoque_atual)
SELECT 
    i,
    'Componente ' || i,
    'tipo',
    1000
FROM generate_series(1,50) i;

INSERT INTO db.tb_fornecedor (id_fornecedor, des_nome, num_cnpj, des_email)
SELECT 
    i,
    'Fornecedor ' || i,
    LPAD(i::text, 14, '0'),
    'fornecedor' || i || '@email.com'
FROM generate_series(1,20) i;

INSERT INTO db.tb_promocao (id_promocao, des_nome, tp_desconto, vlr_desconto, dt_fim)
SELECT 
    i,
    'Promo ' || i,
    'percentual',
    10,
    CURRENT_DATE + INTERVAL '30 days'
FROM generate_series(1,10) i;


INSERT INTO db.tb_clientes (id_cliente, num_cpf, des_nome, dt_nascimento, des_email, num_telefone)
SELECT 
    i,
    LPAD(i::text, 11, '0'),
    'Cliente ' || i,
    DATE '1990-01-01' + (i || ' days')::interval,
    'cliente' || i || '@email.com',
    '1199999' || LPAD(i::text, 4, '0')
FROM generate_series(1,100) i;

-- ================|Tabelas dependentes simples (1:N)|==================

INSERT INTO db.tb_enderecos (id_endereco, id_cliente, num_cep, des_logradouro, num_endereco, des_estado, des_municipio)
SELECT 
    i,
    i,
    LPAD(i::text, 8, '0'),
    'Rua ' || i,
    i::text,
    'SP',
    'Cidade ' || i
FROM generate_series(1,100) i;

INSERT INTO db.tb_produtos (id_produto, des_nome, des_produto, vlr_unitario, id_categoria)
SELECT 
    i,
    'Produto ' || i,
    'Descricao ' || i,
    (10 + i)::numeric(10,2),
    ((i - 1) % 10) + 1
FROM generate_series(1,100) i;

INSERT INTO db.tb_customizacao_valor (
    id_customizacao_valor,
    id_tipo_customizacao,
    des_customizacao,
    vlr_adicional
)
SELECT 
    i,
    ((i - 1) % 10) + 1,                -- garante FK válida (1 a 10)
    'Opcao ' || i,
    (i % 5)::numeric(10,2)
FROM generate_series(1,100) i;

INSERT INTO db.tb_avaliacao_produto (id_avaliacao, id_cliente, id_produto, des_nota, des_comentario)
SELECT 
    i,
    i,
    i,
    5,
    'Produto excelente ' || i
FROM generate_series(1,100) i;


-- ================|Tabelas principais de processo|==================

INSERT INTO db.tb_pedidos (id_pedido, id_cliente, des_status, id_entrega_endereco, id_cobranca_endereco)
SELECT 
    i,
    i,
    'finalizado',
    i,
    i
FROM generate_series(1,100) i;

INSERT INTO db.tb_itens_pedido (
    id_item, id_pedido, id_produto, num_quantidade, vlr_preco_base, vlr_preco_final
)
SELECT 
    i,
    i,
    i,
    1,
    (10 + i)::numeric(10,2),
    (10 + i)::numeric(10,2)
FROM generate_series(1,100) i;


-- ================|Tabelas dependentes (1:1)|==================
INSERT INTO db.tb_envio (id_envio, id_pedido, cod_rastreio, des_status_envio)
SELECT 
    i,
    i,
    'BR' || LPAD(i::text, 10, '0'),
    'entregue'
FROM generate_series(1,100) i;

INSERT INTO db.tb_pagamento (id_pagamento, id_pedido, tp_pagamento, vlr_pago, des_status_pagamento)
SELECT 
    i,
    i,
    'cartao',
    (10 + i)::numeric(10,2),
    'aprovado'
FROM generate_series(1,100) i;


-- ================|Tabelas assossiativas (N:M)|==================

INSERT INTO db.tb_produto_fornecedor (id_produto, id_fornecedor)
SELECT 
    i,
    ((i - 1) % 20) + 1
FROM generate_series(1,100) i;

INSERT INTO db.tb_item_customizacao (id_item, id_customizacao_valor)
SELECT 
    i,
    i
FROM generate_series(1,100) i;

INSERT INTO db.tb_promocao_produto (id_promocao, id_produto)
SELECT 
    ((i - 1) % 10) + 1,
    i
FROM generate_series(1,100) i;

INSERT INTO db.tb_promocao_categoria (id_promocao, id_categoria)
SELECT 
    ((i - 1) % 10) + 1,
    ((i - 1) % 10) + 1
FROM generate_series(1,10) i;


INSERT INTO db.tb_componente_estoque (id_componente, id_produto, qtd_necessaria)
SELECT 
    ((i - 1) % 50) + 1,
    i,
    2
FROM generate_series(1,100) i;
