use master
go
-- Create database
create database db_bank
on  primary (name='db_bank', filename='C:\mssql\data\db_bank.mdf',     size=50Mb, maxsize=150Mb, filegrowth=25Mb)
log on (name='db_bank_log',  filename='C:\mssql\data\db_bank_log.ldf', size=30Mb, maxsize=100Mb, filegrowth=25Mb); 
go

-- Retrieve stored symmetric keys
select * from sys.symmetric_keys
go

-- Create symmetric key (master database)
create master key encryption by password = '23987hxJKL95QYV4369#ghf0%lekjg5k3fd117r$$#1946kcj$n44ncjhdlj'
go

-- Create a certificate
create certificate secure_credit_cards with subject = 'custom credit card number';
go

-- Create symmetric key (current database)
create symmetric key lscck_04
	with algorithm = aes_256
    encryption by certificate secure_credit_cards;


use db_bank

CREATE TABLE rol (
  idrol int NOT NULL,
  rol varchar(20) DEFAULT NULL
);
go

alter table rol add constraint pk_rol primary key(idrol);
go

CREATE TABLE usuario (
  idusuario int NOT NULL,
  nombre varchar(50) DEFAULT NULL,
  correo varchar(100) DEFAULT NULL,
  usuario varchar(15) DEFAULT NULL,
  clave varchar(100) DEFAULT NULL,
  rol int DEFAULT NULL,
  estatus int DEFAULT 1,
);
go

alter table usuario add constraint pk_usuario primary key(idusuario);
go

alter table usuario add constraint fk_usuario_rol foreign key(rol) references rol(idrol);
go

-- Create person table
create table customer(
	cedcustomer varchar(10) not null,
	nombre varchar(30) not null,
	correo varchar(30) not null
);
go

alter table customer add constraint pk_customer primary key(cedcustomer);
go

-- Create example table
create table card_list(
	customer varchar(10) not null,
	creditCard varchar(16) not null,
	encryptedCC varbinary(250) null
);
go

alter table card_list add constraint pk_card_list primary key(creditCard);
go

alter table card_list add constraint fk_card_list_customer foreign key(customer) references customer(cedcustomer);
go

-- EncryptByKey(par_1, par_2, par_3, par_4)
--   par_1: key_GUID to be used to encrypt
--   par_2: value to be stored
--   par_3: add authenticator, only if value = 1
--   par_4: authenticator value

-- Open the symmetric key with which to encrypt the data.
open symmetric key lscck_04 decryption by certificate secure_credit_cards;
go

-- Insert data

INSERT INTO rol (idrol, rol) VALUES
(1, 'administrador'),
(2, 'supervisor'),
(3, 'caja');
go

INSERT INTO usuario (idusuario, nombre, correo, usuario, clave, rol, estatus) VALUES
(1, 'Carlos', 'cmatamoros@bcr.com', 'administrador', EncryptByKey(Key_GUID('lscck_04'),'1234',1, HashBytes('MD5',convert(varbinary,500))), 1, 1),
(2, 'Martin', 'mrodriguez@bcr.com', 'supervisor', EncryptByKey(Key_GUID('lscck_04'),'abcd',1, HashBytes('MD5',convert(varbinary,500))), 2, 1),
(3, 'Karol', 'krojas@bcr.com', 'caja', EncryptByKey(Key_GUID('lscck_04'),'wxyz',1, HashBytes('MD5',convert(varbinary,500))), 3, 1);
go

insert into usuario
values('605960578', 'Juanito', 'juani17@gmail.com');
go

insert into usuario
values('608960578', 'Marian', 'mar15@gmail.com');
go

insert into usuario
values('605900698', 'Lucas', 'lu17@gmail.com');
go

insert into card_list
values('605960578', '6041710012564010', EncryptByKey(Key_GUID('lscck_04'),'605960578',0));
go

insert into card_list
values('608960578', '6042210012564010', EncryptByKey(Key_GUID('lscck_04'),'608960578',0));
go

insert into card_list
values('605960298','6041810012569010',EncryptByKey(Key_GUID('lscck_04'),'605960298',1, HashBytes('SHA1',convert(varbinary,500))));
go

insert into card_list
values('605900698','6041810012569020',EncryptByKey(Key_GUID('lscck_04'),'605900698',1, HashBytes('SHA1',convert(varbinary,500))));
go

-- Close the key
close symmetric key lscck_04;


-- Retrieve data 
select * from usuario;
select * from usuario u 
inner join card_list c
on c.cusID = u.cedusuario



select c.cusID, u.nombre, c.creditCard, c.encryptedCC,
       DecryptByKey(c.encryptedCC) decryptedCC
from usuario u inner join card_list c
on c.cusID = u.cedusuario;


select c.customer, u.nombre, c.creditCard, c.encryptedCC,
       CONVERT(varchar, DecryptByKey(c.encryptedCC,1,HashBytes('SHA1',convert(varbinary,500)))) decryptedCC
from usuario u inner join card_list c
on c.cusID = u.cedusuario