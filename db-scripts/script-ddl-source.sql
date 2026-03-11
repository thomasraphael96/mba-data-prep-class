--Cria o schema ERP
CREATE SCHEMA IF NOT EXISTS erp

-- Cria as tabelas
CREATE TABLE IF NOT EXISTS erp.tb_produtos (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    -- valor_unitario DECIMAL (CHECK valor_unitario > 0),
    valor_unitario NUMERIC(10,2),
    fk_id_cor INTEGER, --foreign key
    fk_id_material INTEGER,
    fk_id_tamanho INTEGER,
    fk_id_categoria INTEGER,
    fk_id_fornecedor INTEGER
);

CREATE TABLE IF NOT EXISTS erp.tb_clientes (
    id_cliente SERIAL PRIMARY KEY,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    dt_nascimento DATE,
    email VARCHAR(100) UNIQUE,
    telefone INTEGER,
    fk_id_endereco INTEGER
)

CREATE TABLE IF NOT EXISTS erp.tb_itens_pedido (
    id_item SERIAL PRIMARY KEY,
    fk_id_produto
)