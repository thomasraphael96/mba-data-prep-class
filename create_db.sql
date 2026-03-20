-- =========================|Schemas|============================
DROP SCHEMA IF EXISTS db CASCADE;
CREATE SCHEMA db;

-- ================|Tabelas independentes (sem FK)|==================
CREATE TABLE db.tb_categoria (
    id_categoria SERIAL PRIMARY KEY,
    des_categoria VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE db.tb_tipo_customizacao (
    id_tipo_customizacao SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE db.tb_estoque (
    id_componente SERIAL PRIMARY KEY,
    des_componente VARCHAR(100) NOT NULL,
    tp_componente VARCHAR(50) NOT NULL,
    qtd_estoque_atual INTEGER NOT NULL
);

CREATE TABLE db.tb_fornecedor (
    id_fornecedor SERIAL PRIMARY KEY,
    des_nome VARCHAR(100) NOT NULL,
    num_cnpj VARCHAR(14) UNIQUE NOT NULL CHECK (length(num_cnpj) = 14),
    des_email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE db.tb_promocao (
    id_promocao SERIAL PRIMARY KEY,
    des_nome VARCHAR(100) NOT NULL,
    tp_desconto VARCHAR(20) CHECK (tp_desconto IN ('percentual', 'fixo')),
    vlr_desconto NUMERIC(10,2),
    dt_inicio DATE DEFAULT CURRENT_DATE,
    dt_fim DATE NOT NULL
);

CREATE TABLE db.tb_clientes (
    id_cliente SERIAL PRIMARY KEY,
    num_cpf VARCHAR(11) UNIQUE NOT NULL CHECK (length(num_cpf) = 11),
    des_nome VARCHAR(100) NOT NULL,
    dt_nascimento DATE NOT NULL,
    des_email VARCHAR(100) UNIQUE NOT NULL,
    num_telefone VARCHAR(20) NOT NULL,
    dt_cadastro DATE DEFAULT CURRENT_DATE
);

-- ================|Tabelas dependentes simples (1:N)|==================

CREATE TABLE db.tb_enderecos (
    id_endereco SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    num_cep VARCHAR(8) NOT NULL CHECK (length(num_cep) = 8),
    des_logradouro VARCHAR(150) NOT NULL,
    num_endereco VARCHAR(10) NOT NULL,
    des_complemento VARCHAR(100),
    des_estado VARCHAR(2) NOT NULL,
    des_municipio VARCHAR(100) NOT NULL,
    tp_endereco_cobranca BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_endereco_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES db.tb_clientes(id_cliente)
);

CREATE TABLE db.tb_produtos (
    id_produto SERIAL PRIMARY KEY,
    des_nome VARCHAR(100) NOT NULL,
    des_produto VARCHAR(100),
    vlr_unitario NUMERIC(10,2) NOT NULL CHECK (vlr_unitario > 0),
    id_categoria INTEGER NOT NULL,

    CONSTRAINT fk_produto_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES db.tb_categoria(id_categoria)
);

CREATE TABLE db.tb_customizacao_valor (
    id_customizacao_valor SERIAL PRIMARY KEY,
    id_tipo_customizacao INTEGER NOT NULL,
    des_customizacao VARCHAR(100) NOT NULL,
    vlr_adicional NUMERIC(10,2) DEFAULT 0,

    CONSTRAINT fk_tipo_customizacao
        FOREIGN KEY (id_tipo_customizacao)
        REFERENCES db.tb_tipo_customizacao(id_tipo_customizacao)
);

CREATE TABLE db.tb_avaliacao_produto (
    id_avaliacao SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    id_produto  INTEGER NOT NULL,
    dt_avaliacao DATE DEFAULT CURRENT_DATE,
    des_comentario VARCHAR(500),
    des_nota INTEGER NOT NULL CHECK (des_nota BETWEEN 1 AND 5),

    CONSTRAINT fk_avaliacao_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES db.tb_clientes(id_cliente),

    CONSTRAINT fk_avaliacao_produto
        FOREIGN KEY (id_produto)
        REFERENCES db.tb_produtos(id_produto)
);

-- ================|Tabelas principais de processo|==================

CREATE TABLE db.tb_pedidos (
    id_pedido SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    dt_pedido DATE DEFAULT CURRENT_DATE,
    des_status VARCHAR(50) NOT NULL,
    id_entrega_endereco INTEGER NOT NULL,
    id_cobranca_endereco INTEGER NOT NULL,

    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES db.tb_clientes(id_cliente),

    CONSTRAINT fk_pedido_entrega
        FOREIGN KEY (id_entrega_endereco)
        REFERENCES db.tb_enderecos(id_endereco),

    CONSTRAINT fk_pedido_cobranca
        FOREIGN KEY (id_cobranca_endereco)
        REFERENCES db.tb_enderecos(id_endereco)
);

CREATE TABLE db.tb_itens_pedido (
    id_item SERIAL PRIMARY KEY,
    id_pedido INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    num_quantidade INTEGER NOT NULL CHECK (num_quantidade > 0),
    vlr_preco_base NUMERIC(10,2) NOT NULL CHECK (vlr_preco_base > 0),
    vlr_preco_final NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_item_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES db.tb_pedidos(id_pedido),

    CONSTRAINT fk_item_produto
        FOREIGN KEY (id_produto)
        REFERENCES db.tb_produtos(id_produto)
);

-- ================|Tabelas dependentes (1:1)|==================

CREATE TABLE db.tb_envio (
    id_envio SERIAL PRIMARY KEY,
    id_pedido INTEGER UNIQUE NOT NULL,
    cod_rastreio VARCHAR(50) UNIQUE NOT NULL,
    des_status_envio VARCHAR(20) NOT NULL,
    dt_envio DATE DEFAULT CURRENT_DATE,

    CONSTRAINT fk_envio_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES db.tb_pedidos(id_pedido)
);

CREATE TABLE db.tb_pagamento (
    id_pagamento SERIAL PRIMARY KEY,
    id_pedido INTEGER UNIQUE NOT NULL,
    tp_pagamento VARCHAR(50) NOT NULL,
    vlr_pago NUMERIC(10,2) NOT NULL,
    des_status_pagamento VARCHAR(50) NOT NULL,

    CONSTRAINT fk_pagamento_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES db.tb_pedidos(id_pedido)
);

-- ================|Tabelas assossiativas (N:M)|==================

CREATE TABLE db.tb_produto_fornecedor (
    id_produto INTEGER NOT NULL,
    id_fornecedor INTEGER NOT NULL,

    PRIMARY KEY (id_produto, id_fornecedor),

    CONSTRAINT fk_pf_produto
        FOREIGN KEY (id_produto)
        REFERENCES db.tb_produtos(id_produto),

    CONSTRAINT fk_pf_fornecedor
        FOREIGN KEY (id_fornecedor)
        REFERENCES db.tb_fornecedor(id_fornecedor)
);

CREATE TABLE db.tb_item_customizacao (
    id_item INTEGER NOT NULL,
    id_customizacao_valor INTEGER NOT NULL,

    PRIMARY KEY (id_item, id_customizacao_valor),

    CONSTRAINT fk_ic_item
        FOREIGN KEY (id_item)
        REFERENCES db.tb_itens_pedido(id_item),

    CONSTRAINT fk_ic_customizacao
        FOREIGN KEY (id_customizacao_valor)
        REFERENCES db.tb_customizacao_valor(id_customizacao_valor)
);

CREATE TABLE db.tb_promocao_produto (
    id_promocao INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,

    PRIMARY KEY (id_promocao, id_produto),

    CONSTRAINT fk_pp_promocao
        FOREIGN KEY (id_promocao)
        REFERENCES db.tb_promocao(id_promocao),

    CONSTRAINT fk_pp_produto
        FOREIGN KEY (id_produto)
        REFERENCES db.tb_produtos(id_produto)
);

CREATE TABLE db.tb_promocao_categoria (
    id_promocao INTEGER NOT NULL,
    id_categoria INTEGER NOT NULL,

    PRIMARY KEY (id_promocao, id_categoria),

    CONSTRAINT fk_pc_promocao
        FOREIGN KEY (id_promocao)
        REFERENCES db.tb_promocao(id_promocao),

    CONSTRAINT fk_pc_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES db.tb_categoria(id_categoria)
);

CREATE TABLE db.tb_componente_estoque (
    id_componente INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    qtd_necessaria INTEGER NOT NULL,

    PRIMARY KEY (id_componente, id_produto),

    CONSTRAINT fk_componente
        FOREIGN KEY (id_componente)
        REFERENCES db.tb_estoque(id_componente),

    CONSTRAINT fk_produto
        FOREIGN KEY (id_produto)
        REFERENCES db.tb_produtos(id_produto)
);
