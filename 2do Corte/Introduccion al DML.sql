/*
Sentencias DML 19-03-2026

autor: (|\mathbb{R}| - 2) + 1
*/

create database if not exists tiendaOnline;
use tiendaOnline;

create table clientes(
  idCliente int primary key auto_increment,
  nombreCliente varchar(100) not null,
  emailCliente varchar(150) unique,
  ciudad varchar(80) null,
  creado_en datetime default now() # Esta vuelta lo que hace es guardar la fecha de cuando se hace el registro
);

create table productos(
  idProducto int primary key auto_increment,
  nombreProducto varchar(120) not null,
  precioProducto decimal(10,2),
  stockProducto int default 0,
  categoriaProducto varchar(60)
);

create table pedido(
  idPedido int primary key auto_increment,
  cantidadProducto int not null,
  fechaPedido date,
  idClienteFK int,
  idProductoFK int,
  foreign key (idClienteFK) references clientes (idCliente),
  foreign key (idProductoFK) references productos (idProducto)
);

-- sin restricciones pq es un backup
create table cliente_backup (
  idClienteBack int primary key auto_increment,
  nombreCliente varchar(100),
  emailCliente varchar(150),
  copiado_en datetime default current_timestamp
);

-- select: consulta general de las tablas
select * from clientes;
select * from productos;
select * from pedido;

-- inserciones
-- insert into nombre_tabla (campo1, campo2, campo3,....) values (value1, value2, value3,....)
-- si el campo es varchar "value"
-- si el campo es autoincrement debe enviar el campo sin poner: ''
-- si el campo es una fecha debe revisar el formato 

describe clientes;
-- agregar 1 registro
insert into clientes(idcliente, nombreCliente, emailCliente, ciudad) values ('','Samuel Alejandro Galindo Martinez','samuela.galindo@urosario.edu.co','Tunja')
insert into clientes(idcliente, nombreCliente, emailCliente, ciudad) values ('','Pedro Wiwi','pedro.wiwi@uniputumayo.edu.co','Santa Jacinta')

select * from clientes; --ya mostrará los registros

-- agregar varios registros

insert into productos (idProducto,nombreProducto, stockProducto, categoriaProducto)
values ('Salsa de Queso AKA Yogur',3000000,32,'Vaca'),
('Un Bolívar',8.28,1,'Bolívar'),
('Pan',500,200,'Vaca'),
('Capar Optimización',1500000,2,'Vaca');

select * from productos; --ahora si hay vainas

insert into cliente_backup (nombreCliente, emailCliente)
select nombreCliente, emailCliente
from clientes
where creado_en<'2024-01-01'; --el < si es actually un 'menor que'

-- update -> una TRANSACCIÓN que nos va a permitir actualizar o modificar los registros en una tabla listo? como es la sintaxis, entonces va
-- update nombreTabla set columna1=valor1, columna2=valor2, ..., columna_n=valor_n where condicion
select * from clientes;

-- Actualizar un campo
update clientes
set ciudad='Barrancabermeja, Putumayo (nullspace)'
where idCliente=1; -- esto es con auto_increment, entonces actualizó al primer cliente

-- Actualizar varios campos
select * from productos;

update productos
set 
precioProducto = 1200000,
stockProducto = 1546
where idProducto = 1;

-- tambien se puede hacer...
-- IMPORTANTE: Siempre poner where al hacer update pq sino cambia todo
update productos
set precioProducto = precioProducto * 0
where categortiaProducto = 'Bolívar'; -- si bota error 1175 sabremos que: toca cambiar cosas Edit -> Preferences -> SQL Editor -> Desactivar Safe Updates -> Restart Xampp -> Hacerle

-- delete -> no adivinarás pero NO LO HAGAS (?) [no recomendable]


-- investigar los métodos de tipo numéricos y caractéres en MySQL (ver 6. del e-aulas)
-- investigar si se puede o no revertir una eliminacion de registros (no se puede). Pista: Rollback asi se puede como
-- Sintaxis delete from {nombre_Tabla} where {condicion}

delete from clientes where idCliente = 2;
-- el martes vemos consultas (operadores: <, >, =, <>, AND, OR, NOT)

insert into clientes (idcliente, nombreCliente, emailCliente, ciudad) values ('Padre','padre@cielo.net')
-- ay dios mio
