/* PARTE I
DDL - Lenguaje de definición de datos

Instrucciones:
CREATE -> no adivinarás 
ALTER -> game (relacion entre tabla y otra)
DROP -> borrar lo que sea
TRUNCATE -> modificar o otras cosas (entre las tablas)

Primero, crear la base de datos.
Toca habilitarla si o si para poder crear tablas.
*/

## Crear la DB -> create database {nombre_base_datos}
create database companiaseguros;

## Habilitar o encender la DB -> use {nombre_DB}
use companiaseguros;

/*Crear tablas
create table {nombre_tabla} (
{campo_1} {tipo_dato} ({tamaño}) {restriccion},
{campo_2} {tipo_dato} ({tamaño}) {restriccion},
{campo_3} {tipo_dato} ({tamaño}) {restriccion},
...
{campo_n} {tipo_dato} ({tamaño}) {restriccion}
);
*/

create table compania(
idCompania varchar(30) primary key,
nit varchar(15) unique not null,
nombreCompania varchar (50) not null,
fechaFundacion date null,
representanteLegal varchar (50) not null
);

create table seguro(
idSeguro int primary key,
fechaInicio date not null,
fechaVencimiento date not null,
fechaExpedicion date not null,
valorAsegurado double not null,
costo double not null,
idCompaniaFK varchar (50) not null,
idAutomovilFK int not null
);

create table automovil(
idAutomovil int primary key,
marca varchar (20) not null,
linea varchar (30) not null,
cilindraje int null,
placa varchar (6) unique not null,
anoFabricacion year not null,
serialChasis varchar(20) null
);

create table accidente(
idAccidente int primary key,
fechaAccidente datetime not null,
heridos int null,
fatalidades int null,
lugar varchar(30) null
);

create table detalleaccidente(
idDetalle int primary key,
idAutomovilFK int not null,
idAccidenteFK int not null
);

/*
Ok, revise el documento que está en e-aulas llamado "22. Ejemplo de sentencias y alteraciones DDL.pdf",
Y esto es lo que entendi de añadir relaciones y FK y etc...
*/

ALTER TABLE seguro
ADD CONSTRAINT FKCompaniaSeguro
FOREIGN KEY (idCompaniaFK)
REFERENCES compania (idCompania);

ALTER TABLE seguro
ADD CONSTRAINT FKAutomovilSeguro
FOREIGN KEY (idAutomovilFK)
REFERENCES automovil (idAutomovil);

ALTER TABLE detalleaccidente
ADD CONSTRAINT FKAutomovilDetalle
FOREIGN KEY (idAutomovilFK)
REFERENCES automovil (idAutomovil);

ALTER TABLE detalleaccidente
ADD CONSTRAINT FKAccidenteDetalle
FOREIGN KEY (idAccidenteFK)
REFERENCES accidente (idAccidente);