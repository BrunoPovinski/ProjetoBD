CREATE DATABASE Sapataria ON
(NAME = sptrprimary, FILENAME = 'C:\BD\prim_sptr.mdf', SIZE = 10MB, MAXSIZE = 50MB, FILEGROWTH = 1MB),
(NAME = ex03secondary, FILENAME = 'C:\BD\secon_sptr.ndf', SIZE = 25MB, MAXSIZE = 100MB, FILEGROWTH = 10%)
LOG ON
(NAME = sptrlog, FILENAME = 'C:\BD\log_sptr.ldf', SIZE = 10MB, MAXSIZE = 30MB, FILEGROWTH = 2MB)
go
USE Sapataria
go
CREATE TABLE Pessoa(
	cpf varchar (11) NOT NULL,
	nome char(30) NOT NULL,
	endereco varchar(30) NOT NULL,
	rg varchar(14) NOT NULL,
	dataNascimento date NOT NULL,
	dataCadastro date NOT NULL,
	PRIMARY KEY (cpf),
	UNIQUE(rg)
)
go
CREATE TABLE Funcionario(
	cod_funcionario smallint IDENTITY NOT NULL,
	cpf varchar(11) NOT NULL,
	cargo varchar(20) NOT NULL,
	salario money NOT NULL,
	PRIMARY KEY (cod_funcionario),
	FOREIGN KEY (cpf) REFERENCES Pessoa
)
go
CREATE TABLE Cliente (
	cod_cliente smallint IDENTITY NOT NULL,
	email varchar(20) NOT NULL,
	cpf varchar(11) NOT NULL,
	PRIMARY KEY (cod_cliente),
	FOREIGN KEY (cpf) references Pessoa
)
go
CREATE TABLE Gerente (
	cod_gerente smallint IDENTITY NOT NULL,
	cod_funcionario smallint NOT NULL,
	ramal int NOT NULL,
	PRIMARY KEY (cod_gerente),
	FOREIGN KEY (cod_funcionario) REFERENCES Funcionario,
	UNIQUE(ramal)
)
go
CREATE TABLE Caixa (
	cod_caixa smallint IDENTITY NOT NULL,
	cod_funcionario smallint NOT NULL,
	PRIMARY KEY (cod_caixa),
	FOREIGN KEY (cod_funcionario) REFERENCES Funcionario
)
go
CREATE TABLE Atendente (
	cod_atendente smallint IDENTITY NOT NULL,
	cod_funcionario smallint NOT NULL,
	PRIMARY KEY (cod_atendente),
	FOREIGN KEY (cod_funcionario) REFERENCES Funcionario
)
go
CREATE TABLE Dependente(
	cod_dependente smallint IDENTITY NOT NULL,
	cod_cliente smallint NOT NULL,
	PRIMARY KEY (cod_dependente),
	FOREIGN KEY (cod_cliente) REFERENCES Cliente
)
go
CREATE TABLE Nota_Fiscal(
	cod_notafiscal smallint IDENTITY NOT NULL,
	cod_cliente smallint NOT NULL,
	cod_atendente smallint NOT NULL,
	data_compra date NOT NULL,
	valor_total money NOT NULL,
	PRIMARY KEY (cod_notafiscal),
	FOREIGN KEY (cod_cliente) REFERENCES Cliente,
	FOREIGN KEY (cod_atendente) REFERENCES Atendente
)
go
CREATE TABLE Produto(
	cod_produto smallint IDENTITY NOT NULL,
	descricao varchar(50) NOT NULL,
	qtd_estoque int NOT NULL,
	marca char(20) NOT NULL,
	preco money NOT NULL,
	tamanho smallint NOT NULL,
	PRIMARY KEY (cod_produto)
)
go
CREATE TABLE ItemDaCompra(
	cod_produto smallint NOT NULL,
	cod_notafiscal smallint NOT NULL,
	quantidade int NOT NULL,
	valor money NOT NULL,
	FOREIGN KEY (cod_produto) REFERENCES Produto,
	FOREIGN KEY (cod_notafiscal) REFERENCES Nota_Fiscal
)
go
CREATE TABLE Fornecedor(
	endereco varchar(30) NOT NULL,
	cnpj varchar(11) NOT NULL,
	telefone int NOT NULL,
	nome varchar(40) NOT NULL,
	PRIMARY KEY (cnpj)
)
go
CREATE TABLE Fornecimento(
	cod_produto smallint NOT NULL,
	cnpj varchar(11) NOT NULL,
	cod_compra smallint IDENTITY NOT NULL,
	qtd_compra int NOT NULL,
	data_compra date NOT NULL,
	FOREIGN KEY (cnpj) REFERENCES Fornecedor,
	FOREIGN KEY (cod_produto) REFERENCES Produto,
	PRIMARY KEY(cod_compra)
)
go
CREATE INDEX INDEXPessoa ON Pessoa (cpf)
go
CREATE INDEX INDEXCliente ON Cliente (cod_cliente)
go
CREATE INDEX INDEXGerente ON Gerente (cod_gerente)
go
CREATE INDEX INDEXCaixa ON Caixa (cod_caixa)
go
CREATE INDEX INDEXProduto ON Produto (cod_produto)
go
CREATE INDEX INDEXNotaFisca ON NotaFiscal (cod_notafiscal)
go
CREATE INDEX INDEXFornecedor ON Fornecedor (cod_fornecedor)
go
CREATE PROCEDURE inserirCliente
@CPF char(11),
@RG char(14),
@nome char(100),
@dataNascimento datetime,
@endereco varchar(150),
@email varchar(50),
@telefone varchar(13)
as
BEGIN TRANSACTION
	INSERT INTO Pessoa(cpf, rg, nome, endereco, dataCadastro, dataNascimento)
		VALUES (@CPF, @RG, @nome, @endereco, GETDATE(), @dataNascimento)
	if @@ROWCOUNT > 0
	BEGIN
		INSERT INTO Cliente (cpf,email) VALUES (@CPF, @email)
			if @@ROWCOUNT > 0
			BEGIN
				COMMIT TRANSACTION
				return 1
			END
			else
			BEGIN
				ROLLBACK TRANSACTION
				return 0
			END
		END
	else
	BEGIN
	ROLLBACK TRANSACTION
	return 0
	END
go
CREATE PROCEDURE inserirDependente
@cod_cliente smallint,
@cod_dependente smallint
as
BEGIN TRANSACTION
	INSERT INTO Dependente VALUES (@cod_cliente, @cod_dependente)
	if @@ROWCOUNT > 0
		BEGIN
			COMMIT TRANSACTION
			return 1
		END
	else
		BEGIN
			ROLLBACK TRANSACTION
			return 0
		END
go
CREATE PROCEDURE inserirCaixa
@CPF char(11),
@RG char(14),
@nome char(100),
@dataNascimento datetime,
@endereco varchar(150),
@cargo varchar(20),
@salario money
as
BEGIN TRANSACTION
	INSERT INTO Pessoa(cpf, rg, nome, endereco, dataNascimento, dataCadastro)
	VALUES (@CPF, @RG, @nome, @endereco, @dataNascimento, GETDATE())
	if @@ROWCOUNT > 0
	BEGIN
		INSERT INTO Funcionario VALUES (@CPF, @cargo, @salario)
		DECLARE @cod_funcionario int
		SELECT @cod_funcionario = SCOPE_IDENTITY()
			if @@ROWCOUNT > 0
			BEGIN
			INSERT INTO Caixa VALUES (@cod_funcionario)
				if @@ROWCOUNT > 0
					BEGIN
						COMMIT TRANSACTION	
						return 1
					END
				else
					BEGIN
						ROLLBACK TRANSACTION
					END
			END
			else
			BEGIN
				ROLLBACK TRANSACTION
				return 0
			END
		END
	else
	BEGIN
		ROLLBACK TRANSACTION
		return 0
	END
go
CREATE PROCEDURE inserirGerente
@CPF char(11),
@RG char(14),
@nome char(100),
@dataNascimento datetime,
@endereco varchar(150),
@cargo varchar(20),
@salario money,
@ramal int
as
BEGIN TRANSACTION
	INSERT INTO Pessoa (cpf, rg, nome, endereco, dataNascimento, dataCadastro)
	VALUES (@CPF, @RG, @nome, @endereco, @dataNascimento, GETDATE())
	if @@ROWCOUNT > 0
	BEGIN
		INSERT INTO Funcionario VALUES (@CPF, @cargo, @salario)
			DECLARE @cod_funcionario int
			SELECT @cod_funcionario = SCOPE_IDENTITY()
			if @@ROWCOUNT > 0
			BEGIN
			INSERT INTO Gerente VALUES(@cod_funcionario, @ramal)
				if @@ROWCOUNT > 0
					BEGIN
						COMMIT TRANSACTION
						return 1
					END
				else
					BEGIN
						ROLLBACK TRANSACTION
					END
			END
			else
			BEGIN
				ROLLBACK TRANSACTION
				return 0
			END
		END
	else
	BEGIN
		ROLLBACK TRANSACTION
		return 0
	END
go
create procedure inserirAtendente
@CPF char(11),
@RG char(14),
@nome char(100),
@dataNascimento datetime,
@endereco varchar(150),
@cargo varchar(20),
@salario money,
@ramal int
as
BEGIN TRANSACTION
	INSERT INTO Pessoa (cpf, rg, nome, endereco, dataNascimento, dataCadastro)
	VALUES (@CPF, @RG, @nome, @endereco, @dataNascimento, GETDATE())
	if @@ROWCOUNT > 0
	BEGIN
		INSERT INTO Funcionario VALUES(@CPF, @cargo, @salario)
			DECLARE @cod_funcionario int
			SELECT @cod_funcionario = SCOPE_IDENTITY()
			if @@ROWCOUNT > 0
			BEGIN
			INSERT INTO Atendente VALUES(@cod_funcionario)
				if @@ROWCOUNT > 0
					BEGIN
						COMMIT TRANSACTION
						return 1
					END
				else
					BEGIN
						ROLLBACK TRANSACTION
					END
			END
			else
			BEGIN
				ROLLBACK TRANSACTION
				return 0
			END
		END
	else
	BEGIN
		ROLLBACK TRANSACTION
		return 0
	END
go
CREATE PROCEDURE inserirProduto
@descricao char(50),
@qtd_estoque int not null,
@marca varchar(20) not null,
@preco money not null,
@tamanho smallint not null
as
BEGIN TRANSACTION
INSERT INTO Produto VALUES(@descricao, @qtd_estoque, @marca, @preco, @tamanho)
	if @@ROWCOUNT > 0
		BEGIN
			COMMIT TRANSACTION
			return 1
		END
	else
		BEGIN
			ROLLBACK TRANSACTION
			return 0
		END

go
CREATE PROCEDURE inserirFornecedor
@ENDereco varchar(30),
@cnpj varchar(11),
@nome varchar(40),
@telefone int
as
BEGIN TRANSACTION
	INSERT INTO Fornecedor VALUES(@endereco, @cnpj, @telefone, @nome)
	if @@ROWCOUNT > 0
		BEGIN
			COMMIT TRANSACTION
			return 1
		END
	else
		BEGIN
			ROLLBACK TRANSACTION
		END
go
CREATE PROCEDURE inserirNotaFiscal
@cod_cliente smallint,
@cod_atendente smallint,
@valor_total money
as
BEGIN TRANSACTION
	INSERT INTO Nota_Fiscal VALUES(@cod_cliente, @cod_atendente, GETDATE(), @valor_total)
	if @@ROWCOUNT > 0
		BEGIN
			COMMIT TRANSACTION
			return 1
		END
	else
		BEGIN
			ROLLBACK TRANSACTION
		END
go
CREATE PROCEDURE inserirItemDaCompra
@cod_produto smallint,
@cod_notafiscal smallint,
@quantidade smallint
as
BEGIN TRANSACTION
	INSERT INTO ItemDaCompra (cod_produto,cod_notafiscal,quantidade) VALUES (@cod_produto, @cod_notafiscal, @quantidade)
	if @@ROWCOUNT > 0
		BEGIN
			COMMIT TRANSACTION
			return 1
		END
	else
		BEGIN
			ROLLBACK TRANSACTION
			return 0
		END
go
CREATE PROCEDURE inserirFornecimento
@qtd_compra smallint,
as
BEGIN TRANSACTION
	INSERT INTO Fornecimento (qtd_compra, data_compra) VALUES (@qtd_compra, GETDATE())
	if @@ROWCOUNT > 0
		BEGIN
			COMMIT TRANSACTION
			return 1
		END
	else
		BEGIN
			ROLLBACK TRANSACTION
			return 0
		END
go
CREATE TRIGGER calcularValor
ON ItemDaCompra FOR INSERT
as
BEGIN TRANSACTION
	UPDATE ItemDaCompra SET valor=(SELECT p.preco*i.quantidade FROM Produto p INNER JOIN inserted i ON p.cod_produto = i.cod_produto)
	if @@ROWCOUNT > 0
		BEGIN
			COMMIT TRANSACTION
		END
	else
		BEGIN
			ROLLBACK TRANSACTION
		END
END
go

CREATE TRIGGER CalcularValorNotaFiscal
ON Nota_Fiscal FOR INSERT
as
	BEGIN
		UPDATE Nota_Fiscal SET valor_total = (SELECT ic.valor FROM ItemDaCompra ic INNER JOIN inserted i ON i.cod_notafiscal=ic.cod_notafiscal)
		if @@ROWCOUNT > 0
			BEGIN
				COMMIT TRANSACTION
			END
		else
			BEGIN
				ROLLBACK TRANSACTION
			END
	END

go

CREATE TRIGGER BaixaNoEstoque
ON ItemDaCompra FOR INSERT
as
	BEGIN
		UPDATE Produto SET qtd_estoque=qtd_estoque - (SELECT i.quantidade FROM inserted i)
		WHERE cod_produto=(SELECT cod_produto FROM inserted)
	END
go

CREATE TRIGGER fornecimentoEstoque
ON Fornecimento FOR INSERT
as
	BEGIN
		UPDATE Produto SET qtd_estoque=qtd_estoque + (SELECT i.qtd_compra FROM inserted i)
		WHERE cod_produto=(SELECT cod_produto FROM inserted)
	END
go
