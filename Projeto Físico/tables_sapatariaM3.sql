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
	quantidade int not null,
	valorTotal_compra money not null,
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
	endereco_fornecedor varchar(30) not null,
	cnpj_fornecedor varchar(11) not null,
	telefone_fornecedor int not null,
	nome_fornecedor varchar(40) not null
	primary key (cnpj_fornecedor),
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
go

create index indexPessoa on Pessoa (cod_pessoa)
go
create index indexProduto on Produto (cod_produto)
go
create index indexFuncionario on Venda (cod_funcionario)
go
create index indexProtocolo on Protocolo (cod_protocolo)
go
create index indexFornecedor on Fornecedor (cod_fornecedor)
go
create index indexCompra on Compra (cod_compra)
go
create index indexAtendimento on Atendimento (cod_atendimento)

go

create procedure inserirCliente
	@CPF char(11),
	@RG char(14),
	@nome char(100),
	@dataNasc datetime,
	@endereco varchar(150),
	@CEP char(8),
	@estado char(2),
	@cidade char(100),
	@email varchar(50),
	@telefone varchar(13),
	@dataCadastro datetime,
	@cod_cliente smallint
as
begin transaction
	insert into Cliente
	values(@cod_cliente, @email)
	if @@ROWCOUNT > 0
		begin
			insert into Pessoa
			values(@CPF, @RG, @nome, @endereco, @CEP, @estado, @cidade, @telefone, @dataCadastro, @dataNascimento)
			if @@ROWCOUNT > 0
				commit transaction
			else
				rollback transaction
		end
	else
		rollback transaction
end

go

create procedure inserirGerente
	@CPF char(11),
	@RG char(14),
	@nome char(100),
	@dataNasc datetime,
	@endereco varchar(150),
	@CEP char(8),
	@estado char(2),
	@cidade char(100),
	@email varchar(50),
	@telefone varchar(13),
	@salario money,
	@cod_gerente smallint,
	@ramal int
as
begin transaction
	insert into Gerente
	values(@cod_gerente, @ramal)
	if @@ROWCOUNT > 0
		begin
			insert into Funcionario
			values(@CPF, @RG, @nome, @dataNasc, @endereco, @CEP, @estado, @cidade, @email, @telefone, @salario)
			if @@ROWCOUNT > 0
				commit transaction
			else
				rollback transaction
		end
	else
		rollback transaction
end

go

create procedure inserirGerente
	@CPF char(11),
	@RG char(14),
	@nome char(100),
	@dataNasc datetime,
	@endereco varchar(150),
	@CEP char(8),
	@estado char(2),
	@cidade char(100),
	@email varchar(50),
	@telefone varchar(13),
	@salario money,
	@cod_caixa smallint
as
begin transaction
insert into Gerente
values(@cod_caixa)
if @@ROWCOUNT > 0
	begin
		insert into Funcionario
		values(@CPF, @RG, @nome, @dataNasc, @endereco, @CEP, @estado, @cidade, @email, @telefone)
		if @@ROWCOUNT > 0
			commit transaction
		else
			rollback transaction
	end
else
	rollback transaction
end

go

create procedure inserirAtendente
	@CPF char(11),
	@RG char(14),
	@nome char(100),
	@dataNasc datetime,
	@endereco varchar(150),
	@CEP char(8),
	@estado char(2),
	@cidade char(100),
	@email varchar(50),
	@telefone varchar(13),
	@salario money,
	@cod_atendente smallint
as
begin transaction
insert into Atendente
values(@cod_atendente)
if @@ROWCOUNT > 0
	begin
		insert into Funcionario
		values(@CPF, @RG, @nome, @dataNasc, @endereco, @CEP, @estado, @cidade, @sexo, @email, @telefone, @celular)
		if @@ROWCOUNT > 0
			commit transaction
		else
			rollback transaction
	end
else
	rollback transaction
end

go

create procedure inserirProduto
	@cod_produto smallint,
	@descricao char(50),
	@quantidade int not null,
	@marca varchar(20) not null,
	@preco money not null,
	@tamanho smallint not null
as
begin transaction
insert into Produto
values(@cod_produto, @descricao, @quantidade, @marca, @preco, @tamanho)
if @@ROWCOUNT > 0
	begin
		commit transaction
	end
else
	rollback transaction
end

go

create procedure inserirFornecedor
	@endereco_fornecedor varchar(30),
	@cnpj_fornecedor varchar(11),
	@telefone_fornecedor int,
	@nome_fornecedor varchar(40)
as
begin transaction
insert into Fornecedor
values(@cnpj_fornecedor ,@endereco_fornecedor, @telefone_fornecedor, @nome_fornecedor)
if @@ROWCOUNT > 0
	begin
		commit transaction
	end
else
	rollback transaction
end

go

create procedure inserirNotaFiscal
	@cod_notafiscal smallint,
	@cod_compra smallint,
	@valor_total money
as
begin transaction
insert into NotaFiscal
values(@cod_notafiscal, @cod_compra, @valor_total)
if @@ROWCOUNT > 0
	begin
		commit transaction
	end
else
	rollback transaction
end

go

create trigger criarNotaFiscal
on Compra for insert
as
insert into NotaFiscal(cod_notafiscal, valor_total) values (inserted.cod_compra, inserted.valorTotal_compra)
	if @@ROWCOUNT > 0
		begin
			commit transaction
		end
	else
		rollback transaction

go
