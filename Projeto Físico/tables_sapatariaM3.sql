CREATE DATABASE sapatariaM3
go
use sapatariaM3
go

CREATE TABLE Pessoa(
	cod_pessoa smallint not null,
	nome char(30) not null,
	endereco varchar(30) not null,
	cpf varchar (11) not null,
	rg varchar (14) not null,
	telefone int not null,

	primary key (cod_pessoa),
	cpf (unique),
	rg (unique)

)
go

CREATE TABLE Funcionario(
	cod_funcionario smallint not null,
	cargo varchar(20) not null,
	salario money not null,
	primary key (cod_funcionario),
	foreign key (cod_pessoa) references Pessoa,
)
go

CREATE TABLE Cliente (
	cod_cliente smallint not null,
	email varchar(20) not null
	primary key (cod_cliente),
	foreign key (cod_pessoa) references Pessoa
)
go

CREATE TABLE Gerente (
	cod_gerente smallint not null,
	ramal int not null,
	primary key (cod_gerente),
	foreign key (cod_funcionario) references Funcionario,
	foreign key (cod_pessoa) references Pessoa
	ramal (unique)
)
go
CREATE TABLE Caixa (
	cod_caixa smallint not null,
	primary key (cod_caixa),
	foreign key (cod_funcionario) references Funcionario
	foreign key (cod_pessoa) references Pessoa
)

CREATE TABLE Atendente (
	cod_atentende smallint not null,
	primary key (cod_atendente),
	foreign key (cod_funcionario) references Funcionario,
	foreign key (cod_pessoa) references Pessoa
)
go

CREATE TABLE Pessoa_fisica (
	cod_pessoaF smallint not null
	primary key (cod_pessoaF),
	foreign key (cod_cliente) references Cliente,
	foreign key (cod_pessoa) references Pessoa
)
go

CREATE TABLE Pessoa_juridica(
	cod_pessoaJ smallint not null,
	nome_fantasia varchar(30) not null
	cnpj varchar(11) not null,
	primary key (cod_pessoaJ),
	foreign key (cod_pessoa) references Pessoa,
	foreign key (cod_cliente) references Cliente,
	unique (cnpj)
)
go

CREATE TABLE Compra(
	cod_compra smallint not null,
	forma_pagamento boolean not null,
	primary key (cod_compra),
	foreign key (cod_cliente) references Cliente
)
go

CREATE TABLE Nota_fiscal(
	cod_notafiscal smallint not null,
	cod_compra smallint not null, /* Adicionar esse atributo no MER */
	valor_total money not null,
	primary key (cod_notafiscal),
	foreign key (cod_compra) references Compra
)
go

CREATE TABLE Produto(
	cod_produto smallint not null,
	descricao varchar(50) not null,
	quantidade int not null,
	marca char(20) not null,
	preco money not null,
	tamanho smallint not null
	primary key (cod_produto),
)
go

CREATE TABLE Fornecedor(
	cod_fornecedor smallint not null,
	endereco_fornecedor varchar(30) not null,
	cnpj_fornecedor varchar(11) not null,
	telefone_fornecedor int not null,
	nome_fornecedor varchar(40) not null
	primary key (cod_fornecedor),
	unique (cnpj_fornecedor)
)
go

CREATE TABLE Atendimento(
	cod_atendimento smallint not null,
	dataAtendimento date not null, /* Adicionar esse atributo no MER */
	horaAtendimento time not null, /* Adicionar esse atributo no MER */
	valor_total money not null,
	cod_atendente smallint not null,
	cod_cliente smallint not null,
	primary key (cod_atendimento),
	foreign key (cod_atendente) references Atendente
	foreign key (cod_cliente) references Cliente
)
