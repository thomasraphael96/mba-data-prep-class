-- ================|Tabelas independentes (sem FK)|==================
INSERT INTO db.tb_categoria (id_categoria, des_categoria)
VALUES
(1, 'Camisetas'),
(2, 'Camisas'),
(3, 'Calças'),
(4, 'Bermudas'),
(5, 'Jaquetas'),
(6, 'Vestidos'),
(7, 'Saias'),
(8, 'Moletom'),
(9, 'Roupas Íntimas'),
(10, 'Acessórios');

INSERT INTO db.tb_tipo_customizacao (id_tipo_customizacao, nome)
VALUES
(1, 'Cor'),
(2, 'Tamanho'),
(3, 'Material'),
(4, 'Estampa'),
(5, 'Texto Personalizado');

INSERT INTO db.tb_estoque 
(id_componente, des_componente, tp_componente, qtd_estoque_atual)
VALUES

(1, 'Algodão', 'material', 1000),
(2, 'Poliéster', 'material', 800),
(3, 'Dry Fit', 'material', 600),
(4, 'Jeans', 'material', 700),
(5, 'Linho', 'material', 400),
(6, 'Moletom', 'material', 500),
(7, 'Couro Sintético', 'material', 300),
(8, 'Malha', 'material', 900);

INSERT INTO db.tb_fornecedor 
(des_nome, num_cnpj, des_email)
VALUES
('Tecidos São Paulo Ltda', '12345678000101', 'contato@tecidossaopaulo.com.br'),
('Malharia Brasil', '22345678000102', 'vendas@malhariabrasil.com.br'),
('Indústria Têxtil Nacional', '32345678000103', 'comercial@itn.com.br'),
('Polímeros e Fibras Ltda', '42345678000104', 'contato@polimerosfibras.com.br'),
('DryFit Performance', '52345678000105', 'vendas@dryfitperf.com.br'),
('Jeans Factory Brasil', '62345678000106', 'contato@jeansfactory.com.br'),
('Linho Premium Tecidos', '72345678000107', 'vendas@linhopremium.com.br'),
('Moletom & Conforto', '82345678000108', 'contato@moletomconforto.com.br'),
('CouroTech Sintéticos', '92345678000109', 'comercial@couro-tech.com.br'),
('Malhas e Tecidos Gerais', '13345678000110', 'vendas@malhasgerais.com.br'),
('Tecelagem Paulista', '14345678000111', 'contato@tecelagemp.com.br'),
('Fábrica de Tecidos Sul', '15345678000112', 'vendas@tecidossul.com.br'),
('Brasil Fios e Tecidos', '16345678000113', 'contato@brasilfios.com.br'),
('Indústria de Malhas SP', '17345678000114', 'comercial@malhassp.com.br'),
('Têxtil Premium Brasil', '18345678000115', 'vendas@textilpremium.com.br'),
('Fornecedor Nacional de Tecidos', '19345678000116', 'contato@fnt.com.br'),
('Tecidos e Malhas RJ', '20345678000117', 'vendas@tmrj.com.br'),
('Indústria de Tecidos MG', '21345678000118', 'contato@itmg.com.br'),
('Tecelagem Moderna', '23345678000119', 'comercial@tecelagemmoderna.com.br'),
('Brasil Tecidos e Fibras', '24345678000120', 'vendas@btf.com.br');


INSERT INTO db.tb_promocao 
(id_promocao, des_nome, tp_desconto, vlr_desconto, dt_inicio, dt_fim)

SELECT
    i,

    -- nomes mais realistas
    (ARRAY[
        'Promoção de Verão',
        'Liquidação de Inverno',
        'Black Friday',
        'Semana do Cliente',
        'Outlet Relâmpago',
        'Desconto Progressivo',
        'Queima de Estoque',
        'Volta às Aulas',
        'Promoção Especial',
        'Festival de Ofertas'
    ])[i],

    -- tipo variando
    (ARRAY['percentual','fixo'])[(floor(random()*2)+1)::int],

    -- valor coerente com tipo
    CASE 
        WHEN (i % 2) = 0 THEN (5 + random()*25)::numeric(5,2)   -- % (5% a 30%)
        ELSE (10 + random()*100)::numeric(10,2)                 -- valor fixo
    END,

    -- início nos últimos 30 dias
    CURRENT_DATE - ((random()*30)::int * INTERVAL '1 day'),

    -- fim depois do início
    CURRENT_DATE + ((random()*30 + 5)::int * INTERVAL '1 day')

FROM generate_series(1,10) i;


INSERT INTO db.tb_clientes 
(num_cpf, des_nome, dt_nascimento, des_email, num_telefone, dt_cadastro)
SELECT 
    (1 + floor(random()*9))::int || LPAD((random()*9999999999)::bigint::text, 10, '0') AS num_cpf,
    
    (ARRAY[
        'Lucas Almeida','Mariana Souza','Pedro Costa','Juliana Martins','Rafael Oliveira',
        'Camila Ferreira','Bruno Rodrigues','Fernanda Lima','Gabriel Santos','Patricia Gomes',
        'Carlos Eduardo','Aline Barros','Ricardo Teixeira','Larissa Melo','Thiago Ribeiro',
        'Beatriz Carvalho','Felipe Rocha','Amanda Nunes','Daniel Alves','Renata Lopes',
        'João Victor','Vanessa Pinto','Eduardo Mendes','Tatiane Duarte','André Freitas',
        'Bianca Campos','Rodrigo Pires','Carolina Borges','Gustavo Araujo','Elaine Moura',
        'Leonardo Batista','Priscila Farias','Diego Cavalcante','Simone Rezende','Marcelo Peixoto',
        'Julio Cesar','Isabela Castro','Vinicius Moreira','Claudia Matos','Sergio Cardoso',
        'Paulo Henrique','Debora Ribeiro','Vitor Hugo','Natália Teixeira','Fábio Fernandes',
        'Cristiane Alves','Roberto Dias','Leticia Monteiro','Igor Martins','Sandra Correia'
    ])[((i - 1) % 50) + 1] AS des_nome,

    CURRENT_DATE - ((18 + (random()*52)::int) * INTERVAL '1 year') AS dt_nascimento,

    LOWER(REPLACE(
        (ARRAY[
        'Lucas Almeida','Mariana Souza','Pedro Costa','Juliana Martins','Rafael Oliveira',
        'Camila Ferreira','Bruno Rodrigues','Fernanda Lima','Gabriel Santos','Patricia Gomes',
        'Carlos Eduardo','Aline Barros','Ricardo Teixeira','Larissa Melo','Thiago Ribeiro',
        'Beatriz Carvalho','Felipe Rocha','Amanda Nunes','Daniel Alves','Renata Lopes',
        'João Victor','Vanessa Pinto','Eduardo Mendes','Tatiane Duarte','André Freitas',
        'Bianca Campos','Rodrigo Pires','Carolina Borges','Gustavo Araujo','Elaine Moura',
        'Leonardo Batista','Priscila Farias','Diego Cavalcante','Simone Rezende','Marcelo Peixoto',
        'Julio Cesar','Isabela Castro','Vinicius Moreira','Claudia Matos','Sergio Cardoso',
        'Paulo Henrique','Debora Ribeiro','Vitor Hugo','Natália Teixeira','Fábio Fernandes',
        'Cristiane Alves','Roberto Dias','Leticia Monteiro','Igor Martins','Sandra Correia'
        ])[((i - 1) % 50) + 1]
    ,' ', '.')) || '@email.com' AS des_email,

    '119' || (1 + floor(random()*9))::int || LPAD(((random()*9999999)::int + i)::text, 7, '0') AS num_telefone,

    CURRENT_DATE - ((i * 3) % 365) * INTERVAL '1 day' AS dt_cadastro

FROM generate_series(1,50) i;

-- ================|Tabelas dependentes simples (1:N)|==================

INSERT INTO db.tb_enderecos 
( id_cliente, num_cep, des_logradouro, num_endereco, des_estado, des_municipio, tp_endereco_cobranca)

-- ================= CLIENTES COM 1 ENDEREÇO =================
SELECT
    i,

    LPAD((random()*99999999)::int::text, 8, '0'),

    logradouro,
    (floor(random()*9999)+1)::int::text,

    estado,
    cidade,

    TRUE

FROM (
    SELECT 
        i,

        -- estado + cidade coerente
        (ARRAY['SP','RJ','MG','PR','RS'])[(i % 5)+1] AS estado,

        (ARRAY[
            'São Paulo','Rio de Janeiro','Belo Horizonte','Curitiba','Porto Alegre'
        ])[(i % 5)+1] AS cidade,

        -- logradouros reais
        (ARRAY[
            'Avenida Paulista',
            'Rua Augusta',
            'Rua da Consolação',
            'Avenida Brasil',
            'Rua XV de Novembro',
            'Avenida Atlântica',
            'Rua Oscar Freire',
            'Avenida Brigadeiro Faria Lima',
            'Rua Sete de Setembro',
            'Avenida Getúlio Vargas'
        ])[(i % 10)+1] AS logradouro

    FROM generate_series(1,25) i
) base

UNION ALL

-- ================= CLIENTES COM 2 ENDEREÇOS =================
-- cobrança = TRUE
SELECT
    i + 25,

    LPAD((random()*99999999)::int::text, 8, '0'),

    logradouro,
    (floor(random()*9999)+1)::int::text,

    estado,
    cidade,

    TRUE

FROM (
    SELECT 
        i,

        (ARRAY['SP','RJ','MG','PR','RS'])[(i % 5)+1] AS estado,

        (ARRAY[
            'Campinas','Niterói','Uberlândia','Londrina','Caxias do Sul'
        ])[(i % 5)+1] AS cidade,

        (ARRAY[
            'Avenida Norte Sul',
            'Rua Barão de Jaguara',
            'Rua Visconde do Rio Branco',
            'Avenida Afonso Pena',
            'Rua Marechal Deodoro',
            'Avenida Paraná',
            'Rua Bento Gonçalves',
            'Avenida Dom Pedro I',
            'Rua Goiás',
            'Avenida Independência'
        ])[(i % 10)+1] AS logradouro

    FROM generate_series(1,25) i
) base

UNION ALL

-- entrega = FALSE
SELECT
    i + 25,

    LPAD((random()*99999999)::int::text, 8, '0'),

    logradouro,
    (floor(random()*9999)+1)::int::text,

    estado,
    cidade,

    FALSE

FROM (
    SELECT 
        i,

        (ARRAY['SP','RJ','MG','PR','RS'])[(i % 5)+1] AS estado,

        (ARRAY[
            'Campinas','Niterói','Uberlândia','Londrina','Caxias do Sul'
        ])[(i % 5)+1] AS cidade,

        (ARRAY[
            'Rua das Acácias',
            'Rua das Palmeiras',
            'Rua dos Pinheiros',
            'Rua das Laranjeiras',
            'Rua das Hortênsias',
            'Rua dos Jasmins',
            'Rua das Oliveiras',
            'Rua das Magnólias',
            'Rua das Azaleias',
            'Rua dos Ipês'
        ])[(i % 10)+1] AS logradouro

    FROM generate_series(1,25) i
) base;

INSERT INTO db.tb_produtos (des_nome, des_produto, vlr_unitario, id_categoria)
VALUES
-- CAMISETAS (1)
('Camiseta Básica', 'Camiseta casual para uso diário', 39.90, 1),
('Camiseta Oversized', 'Modelagem ampla estilo moderno', 69.90, 1),
('Camiseta Manga Longa', 'Camiseta com mangas longas', 59.90, 1),
('Camiseta Regata', 'Camiseta sem mangas', 34.90, 1),
('Camiseta Esportiva', 'Camiseta leve para atividades físicas', 49.90, 1),

-- CAMISAS (2)
('Camisa Social', 'Camisa para ocasiões formais', 89.90, 2),
('Camisa Casual', 'Camisa confortável para o dia a dia', 79.90, 2),
('Camisa Polo', 'Camisa com gola polo casual', 69.90, 2),

-- CALÇAS (3)
('Calça Básica', 'Calça versátil para uso diário', 119.90, 3),
('Calça Alfaiataria', 'Calça social elegante', 149.90, 3),
('Calça Skinny', 'Modelagem ajustada ao corpo', 129.90, 3),
('Calça Jogger', 'Estilo esportivo com elástico', 109.90, 3),

-- BERMUDAS (4)
('Bermuda Casual', 'Bermuda para uso diário', 69.90, 4),
('Bermuda Esportiva', 'Bermuda leve para treino', 59.90, 4),

-- JAQUETAS (5)
('Jaqueta', 'Jaqueta para clima frio', 159.90, 5),

-- VESTIDOS (6)
('Vestido Casual', 'Vestido leve para o dia a dia', 99.90, 6),

-- SAIAS (7)
('Saia', 'Saia versátil feminina', 79.90, 7),

-- MOLETOM (8)
('Moletom', 'Peça de frio confortável', 119.90, 8),

-- ROUPAS ÍNTIMAS (9)
('Cueca', 'Peça íntima masculina', 29.90, 9),
('Sutiã', 'Peça íntima feminina', 49.90, 9),

-- ACESSÓRIOS (10)
('Boné', 'Acessório casual', 39.90, 10),
('Cinto', 'Acessório funcional', 59.90, 10);

INSERT INTO db.tb_customizacao_valor 
(id_customizacao_valor, id_tipo_customizacao, des_customizacao, vlr_adicional)
VALUES

-- ================= COR (1) =================
(1, 1, 'Preto', 0),
(2, 1, 'Branco', 0),
(3, 1, 'Azul', 0),
(4, 1, 'Vermelho', 0),
(5, 1, 'Cinza', 0),
(6, 1, 'Verde', 0),
(7, 1, 'Bege', 0),
(8, 1, 'Rosa', 0),

-- ================= TAMANHO (2) =================
(20, 2, 'PP', 0),
(21, 2, 'P', 0),
(22, 2, 'M', 0),
(23, 2, 'G', 0),
(24, 2, 'GG', 5.00),
(25, 2, 'XG', 7.00),

-- ================= MATERIAL (3) =================
(40, 3, 'Algodão', 0),
(41, 3, 'Poliéster', 0),
(42, 3, 'Dry Fit', 10.00),
(43, 3, 'Jeans', 15.00),
(44, 3, 'Linho', 20.00),
(45, 3, 'Moletom', 10.00),
(46, 3, 'Couro Sintético', 25.00),
(47, 3, 'Malha', 5.00),

-- ================= ESTAMPA (4) =================
(60, 4, 'Sem Estampa', 0),
(61, 4, 'Logo Pequena', 10.00),
(62, 4, 'Logo Média', 15.00),
(63, 4, 'Estampa Grande', 20.00),
(64, 4, 'Estampa Total', 30.00),

-- ================= TEXTO (5) =================
(80, 5, 'Sem Texto', 0),
(81, 5, 'Nome Personalizado', 15.00),
(82, 5, 'Número', 10.00),
(83, 5, 'Frase Curta', 20.00),
(84, 5, 'Frase Longa', 30.00);


INSERT INTO db.tb_avaliacao_produto
(id_cliente, id_produto, des_nota, des_comentario)

SELECT
    c.id_cliente,
    p.id_produto,
    (floor(random()*5)+1)::int,
    'Produto muito bom'

FROM db.tb_clientes c
JOIN db.tb_produtos p ON TRUE

WHERE c.id_cliente % 2 = 0;


-- ================|Tabelas principais de processo|==================

INSERT INTO db.tb_pedidos 
(id_cliente, dt_pedido, des_status, id_entrega_endereco, id_cobranca_endereco)

SELECT
    c.id_cliente,

    -- datas distribuídas (até 120 dias atrás)
    CURRENT_DATE - ((random()*120)::int * INTERVAL '1 day'),

    -- status variados
    (ARRAY[
        'pendente',
        'processando',
        'enviado',
        'entregue',
        'cancelado'
    ])[(floor(random()*5)+1)::int],

    -- entrega
    COALESCE(
        MAX(CASE WHEN e.tp_endereco_cobranca = FALSE THEN e.id_endereco END),
        MAX(e.id_endereco)
    ),

    -- cobrança
    MAX(CASE WHEN e.tp_endereco_cobranca = TRUE THEN e.id_endereco END)

FROM db.tb_clientes c

JOIN db.tb_enderecos e 
    ON e.id_cliente = c.id_cliente

-- 🔥 aqui está o segredo
JOIN generate_series(1, (random()*4 + 1)::int) g(n) 
    ON TRUE

GROUP BY c.id_cliente, g.n;

INSERT INTO db.tb_itens_pedido
(id_pedido, id_produto, num_quantidade, vlr_preco_base, vlr_preco_final)

SELECT
    p.id_pedido,
    pr.id_produto,
    (floor(random()*3)+1)::int,
    pr.vlr_unitario,
    pr.vlr_unitario -- depois você pode somar customização

FROM db.tb_pedidos p
JOIN db.tb_produtos pr 
    ON TRUE
WHERE pr.id_produto <= ((p.id_pedido % 5) + 1);


-- ================|Tabelas dependentes (1:1)|==================
INSERT INTO db.tb_envio 
(id_pedido, cod_rastreio, des_status_envio, dt_envio)

SELECT
    p.id_pedido,

    -- código estilo correios
    'BR' || LPAD(p.id_pedido::text, 10, '0'),

    -- status coerente com pedido
    CASE 
        WHEN p.des_status = 'pendente' THEN 'aguardando envio'
        WHEN p.des_status = 'processando' THEN 'preparando'
        WHEN p.des_status = 'enviado' THEN 'em transporte'
        WHEN p.des_status = 'entregue' THEN 'entregue'
        WHEN p.des_status = 'cancelado' THEN 'cancelado'
    END,

    -- data de envio depois do pedido
    p.dt_pedido + ((random()*5)::int * INTERVAL '1 day')

FROM db.tb_pedidos p

-- 🚨 só gera envio para pedidos válidos
WHERE p.des_status IN ('processando', 'enviado', 'entregue');


INSERT INTO db.tb_pagamento 
(id_pedido, tp_pagamento, vlr_pago, des_status_pagamento)

SELECT
    p.id_pedido,

    -- tipos variados
    (ARRAY[
        'cartao_credito',
        'cartao_debito',
        'pix',
        'boleto'
    ])[(floor(random()*4)+1)::int],

    -- valor baseado nos itens (simulado por enquanto)
    (50 + random()*300)::numeric(10,2),

    -- status coerente com pedido
    CASE 
        WHEN p.des_status = 'cancelado' THEN 'cancelado'
        WHEN p.des_status = 'pendente' THEN 'pendente'
        ELSE 'aprovado'
    END

FROM db.tb_pedidos p;

-- ================|Tabelas assossiativas (N:M)|==================

INSERT INTO db.tb_produto_fornecedor (id_produto, id_fornecedor)

SELECT 
    p.id_produto,
    f.id_fornecedor

FROM db.tb_produtos p

JOIN db.tb_fornecedor f 
    ON TRUE

-- 🔥 controla quantos fornecedores por produto
WHERE f.id_fornecedor <= ((p.id_produto % 3) + 1);

INSERT INTO db.tb_item_customizacao (id_item, id_customizacao_valor)

SELECT 
    i.id_item,
    cv.id_customizacao_valor

FROM db.tb_itens_pedido i

JOIN db.tb_customizacao_valor cv 
    ON cv.id_tipo_customizacao IN (1,2,3) -- cor, tamanho, material

WHERE 
    (
        -- garante 1 valor de cada tipo por item
        (cv.id_tipo_customizacao = 1 AND cv.id_customizacao_valor = ((i.id_item -1) % 8) + 1)
        OR
        (cv.id_tipo_customizacao = 2 AND cv.id_customizacao_valor = ((i.id_item -1) % 6) + 20)
        OR
        (cv.id_tipo_customizacao = 3 AND cv.id_customizacao_valor = ((i.id_item -1) % 8) + 40)
    );

INSERT INTO db.tb_promocao_produto (id_promocao, id_produto)

SELECT 
    pr.id_promocao,
    p.id_produto

FROM db.tb_promocao pr

JOIN db.tb_produtos p 
    ON TRUE

-- 🔥 controla quantos produtos entram em cada promoção
WHERE p.id_produto % pr.id_promocao = 0;


INSERT INTO db.tb_promocao_categoria (id_promocao, id_categoria)

SELECT 
    pr.id_promocao,
    c.id_categoria

FROM db.tb_promocao pr

JOIN db.tb_categoria c 
    ON TRUE

-- 🔥 distribui promoções entre categorias
WHERE c.id_categoria % pr.id_promocao <= 1;


INSERT INTO db.tb_componente_estoque 
(id_componente, id_produto, qtd_necessaria)

SELECT 
    e.id_componente,
    p.id_produto,

    -- quantidade base por tipo de produto
    CASE 
        WHEN c.des_categoria IN ('Camisetas', 'Camisas') THEN 2
        WHEN c.des_categoria IN ('Calças', 'Jaquetas') THEN 3
        WHEN c.des_categoria IN ('Bermudas', 'Saias') THEN 2
        ELSE 1
    END AS qtd_necessaria

FROM db.tb_produtos p

JOIN db.tb_categoria c 
    ON c.id_categoria = p.id_categoria

JOIN db.tb_estoque e 
    ON 1=1  -- produto pode usar qualquer material (modelo flexível)
;
