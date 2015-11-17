CREATE DATABASE sapatariaM3
go
use sapatariaM3
go
CREATE TABLE Pessoa(
cpf varchar (11) not null,
nome char(30) not null,
endereco varchar(30) not null,
rg varchar(14) not null,
dataNascimento date not null,
dataCadastro date not null,
primary key (cpf),
unique(rg)
)
go
CREATE TABLE Funcionario(
cod_funcionario smallint not null,
cpf varchar(11) not null,
cargo varchar(20) not null,
salario money not null,
primary key (cod_funcionario),
foreign key (cpf) references Pessoa,
)
go
CREATE TABLE Cliente (
cod_cliente smallint not null,
email varchar(20) not null,
cpf varchar(11) not null,
primary key (cod_cliente),
foreign key (cpf) references Pessoa
)
go
CREATE TABLE Gerente (
cod_gerente smallint not null,
cod_funcionario smallint not null,
ramal int not null,
primary key (cod_gerente),
foreign key (cod_funcionario) references Funcionario,
unique(ramal)
)
go
CREATE TABLE Caixa (
cod_caixa smallint not null,
cod_funcionario smallint not null,
primary key (cod_caixa),
foreign key (cod_funcionario) references Funcionario
)
go
CREATE TABLE Atendente (
cod_atendente smallint not null,
cod_funcionario smallint not null,
primary key (cod_atendente),
foreign key (cod_funcionario) references Funcionario,
)
go
CREATE TABLE Dependente(
cod_dependente smallint not null,
cod_cliente smallint not null,
primary key (cod_dependente),
foreign key (cod_cliente) references Cliente
)
go
CREATE TABLE Nota_Fiscal(
cod_notafiscal smallint not null,
cod_cliente smallint not null,
cod_atendente smallint not null,
data_compra date not null,
valor_total money not null
primary key (cod_notafiscal),
foreign key (cod_cliente) references Cliente,
foreign key (cod_atendente) references Atendente
)
go
CREATE TABLE Produto(
cod_produto smallint not null,
descricao varchar(50) not null,
qtd_estoque int not null,
marca char(20) not null,
preco money not null,
tamanho smallint not null
primary key (cod_produto),
)
go
CREATE TABLE ItemDaCompra(
cod_produto smallint not null,
cod_notafiscal smallint not null,
quantidade int not null,
valor money not null,
foreign key (cod_produto) references Produto,
foreign key (cod_notafiscal) references Nota_Fiscal
)
/*drop table ItemDaCompra*/
go
CREATE TABLE Fornecedor(
endereco varchar(30) not null,
cnpj varchar(11) not null,
telefone int not null,
nome varchar(40) not null
primary key (cnpj),
)
go
create index indexPessoa on Pessoa (cpf)
go
create index indexCliente on Cliente (cod_cliente)
go
create index indexGerente on Gerente (cod_gerente)
go
create index indexCaixa on Caixa (cod_caixa)
go
create index indexProduto on Produto (cod_produto)
go
create index indexNotaFisca on NotaFiscal (cod_notafiscal)
go
create index indexFornecedor on Fornecedor (cod_fornecedor)
go
create procedure inserirCliente
@CPF char(11),
@RG char(14),
@nome char(100),
@dataNascimento datetime,
@endereco varchar(150),
@email varchar(50),
@telefone varchar(13),
@dataCadastro datetime,
@cod_cliente smallint
as
BEGIN TRANSACTION
	insert into Cliente values(@CPF, @cod_cliente, @email)
	if @@ROWCOUNT > 0
	BEGIN
		insert into Pessoa(cpf, rg, nome, endereco, dataCadastro, dataNascimento)
		values(@CPF, @RG, @nome, @endereco, @dataCadastro, @dataNascimento)
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
/* Não está funcionando ainda */
create procedure inserirDependente
@cod_cliente smallint not null,
@cod_dependente smallint not null
as
begin transaction
	insert into Dependente values(@cod_cliente, @cod_dependente)
	if @@ROWCOUNT > 0
		begin
		commit transaction
		return 1
		end
	else
		begin
		rollback transaction
		return 0
		end
go
create procedure inserirCaixa
@CPF char(11),
@RG char(14),
@nome char(100),
@dataNascimento datetime,
@cod_caixa smallint,
@cod_funcionario smallint,
@endereco varchar(150),
@cargo varchar(20),
@salario money
as
BEGIN TRANSACTION
	insert into Caixa values(@cod_caixa, @cod_funcionario)
	if @@ROWCOUNT > 0
	BEGIN
		insert into Funcionario values(@CPF, @cod_funcionario, @cargo, @salario)
			if @@ROWCOUNT > 0
			BEGIN
				insert into Pessoa(cpf, rg, nome, endereco, dataNascimento)
				values(@CPF, @RG, @nome, @endereco, @dataNascimento)
				if @@ROWCOUNT > 0
					begin
					commit transaction
					return 1
					end
				else
					begin
						rollback transaction
					end
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
create procedure inserirGerente
@CPF char(11),
@RG char(14),
@nome char(100),
@dataNascimento datetime,
@cod_gerente smallint,
@cod_funcionario smallint,
@endereco varchar(150),
@cargo varchar(20),
@salario money,
@ramal int
as
BEGIN TRANSACTION
	insert into Gerente values(@cod_funcionario, @cod_gerente, @ramal)
	if @@ROWCOUNT > 0
	BEGIN
		insert into Funcionario values(@CPF, @cod_funcionario, @cargo, @salario)
			if @@ROWCOUNT > 0
			BEGIN
				insert into Pessoa(cpf, rg, nome, endereco, dataNascimento)
				values(@CPF, @RG, @nome, @endereco, @dataNascimento)
				if @@ROWCOUNT > 0
					begin
					commit transaction
					return 1
					end
				else
					begin
						rollback transaction
					end
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
@cod_atendente smallint,
@cod_funcionario smallint,
@endereco varchar(150),
@cargo varchar(20),
@salario money,
@ramal int
as
BEGIN TRANSACTION
	insert into Atendente values(@cod_funcionario, @cod_atendente)
	if @@ROWCOUNT > 0
	BEGIN
		insert into Funcionario values(@CPF, @cod_funcionario, @cargo, @salario)
			if @@ROWCOUNT > 0
			BEGIN
				insert into Pessoa(cpf, rg, nome, endereco, dataNascimento)
				values(@CPF, @RG, @nome, @endereco, @dataNascimento)
				if @@ROWCOUNT > 0
					begin
					commit transaction
					return 1
					end
				else
					begin
						rollback transaction
					end
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
create procedure inserirProduto
@cod_produto smallint,
@descricao char(50),
@qtd_estoque int not null,
@marca varchar(20) not null,
@preco money not null,
@tamanho smallint not null
as
begin transaction
insert into Produto values(@cod_produto, @descricao, @qtd_estoque, @marca, @preco, @tamanho)
	if @@ROWCOUNT > 0
		begin
			commit transaction
			return 1
		end
	else
		begin
			rollback transaction
			return 0
		end

go
create procedure inserirFornecedor
@endereco varchar(30),
@cnpj varchar(11),
@nome varchar(40),
@telefone int
as
begin transaction
	insert into Fornecedor values(@endereco, @cnpj, @telefone, @nome)
	if @@ROWCOUNT > 0
		begin
			commit transaction
			return 1
		end
	else
		begin
			rollback transaction
		end
go
create procedure inserirNotaFiscal
@cod_notafiscal smallint,
@cod_cliente smallint,
@cod_atendente smallint,
@data_compra date,
@valor_total money
as
begin transaction
	insert into Nota_Fiscal values(@cod_notafiscal, @cod_cliente, @cod_atendente, @data_compra, @valor_total)
	if @@ROWCOUNT > 0
		begin
			commit transaction
			return 1
		end
	else
		begin
			rollback transaction
		end
go
create procedure inserirItemDaCompra
@cod_produto smallint,
@cod_notafiscal smallint,
@quantidade smallint
as
begin transaction
	insert into ItemDaCompra values(@cod_produto, @cod_notafiscal, @quantidade)
	if @@ROWCOUNT > 0
		begin
			commit transaction
			return 1
		end
	else
		begin
			rollback transaction
		end
go

create trigger calcularValor
on ItemDaCompra for insert
as
begin transaction
	update ItemDaCompra set valor=(Select p.preco*i.quantidade from Produto p inner join inserted i on p.cod_produto = i.cod_produto)
	if @@ROWCOUNT > 0
		begin
			commit transaction
		end
	else
		begin
			rollback transaction
		end

go

create trigger CalcularValorNotaFiscal
on Nota_Fiscal for insert
as
	begin
		update Nota_Fiscal set valor_total=(Select ic.valor from ItemDaCompra ic inner join inserted i on i.cod_notafiscal=ic.cod_notafiscal) 
	end