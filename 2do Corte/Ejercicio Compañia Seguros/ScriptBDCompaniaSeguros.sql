/*
-----------------------------------------------------
Script:        	ScriptBaseDatosCompaniaSeguros.sql
Descripción:   	Construir la base de datos descrita por el modelo relacional del ejercicio de Compañía de Seguros. 
				Este MR se puede encontrar en mi repo público.

Autor:         	Santiago Velandia
Fecha:         	2026-Mar-16
Tipo:		   	DDL
Versión:		2.0

Base de datos: companiaseguros

Notas:
- Esta es la continuación del ejercicio Compañía Seguros. A la parte 1 le había hecho commit el Mar 15 2026, 10:19 PM GMT-05
- La tabla a la que le cambiaré el nombre es a 'seguro'.
- La tabla a la que le eliminaré un campo es 'automovil'.
- La llave foránea que eliminaré será 'FKAutomovilDetalle', en la tabla 'detalleaccidente'.
En el final del script están estos cambios.
-----------------------------------------------------
*/

create database companiaseguros;

use companiaseguros;

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

ALTER TABLE seguro
ADD CONSTRAINT FKCompaniaSeguro
FOREIGN KEY (idCompaniaFK)
REFERENCES compania (idCompania);

ALTER TABLE seguro
ADD CONSTRAINT FKAutomovilSeguro
FOREIGN KEY (idAutomovilFK)
REFERENCES automovil (idAutomovil);

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

ALTER TABLE detalleaccidente
ADD CONSTRAINT FKAutomovilDetalle
FOREIGN KEY (idAutomovilFK)
REFERENCES automovil (idAutomovil);

ALTER TABLE detalleaccidente
ADD CONSTRAINT FKAccidenteDetalle
FOREIGN KEY (idAccidenteFK)
REFERENCES accidente (idAccidente);

# 1. Cambiar el nombre de cualquier tabla
ALTER TABLE seguro RENAME poliza;

# 2. Eliminar un campo de cualquier tabla
ALTER TABLE automovil DROP cilindraje;

# 3. Borrar una FK. Me di cuenta que esto borra la FK pero NO elimina el campo dentro de la tabla soooo. 
ALTER TABLE detalleaccidente DROP FOREIGN KEY FKAutomovilDetalle;

# Si se quiere eliminar el campo para que no quede 'idAutomovilFK' flotando por ahí ya tocaría hacer:
# ALTER TABLE detalleaccidente DROP idAutomovilFK

/*
-------------------------------------------------------
Note to self:
El script con todos los comentarios está en mi e-aulas.
-------------------------------------------------------
*/