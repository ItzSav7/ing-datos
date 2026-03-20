/*
-----------------------------------------------------
Autor:         	Santiago Velandia
Fecha:         	2026-Mar-19

Base de datos: tiendaOnline

Notas:
- Al final están las instrucciones que se pedían de tarea.
-----------------------------------------------------
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

create table cliente_backup (
  idClienteBack int primary key auto_increment,
  nombreCliente varchar(100),
  emailCliente varchar(150),
  copiado_en datetime default now()
);

insert into clientes (nombreCliente, emailCliente, ciudad) 
values ('Samuel Alejandro Galindo Martínez','samuela.galindo@urosario.edu.co','Tunja'), 
('Ana Isabel Gómez','rectoria@urosario.edu.co','Sáchica'),
('Pedro Vicente Coral','pedroelescamoso@showsazo.net','Bogotá');

insert into productos (nombreProducto, precioProducto, stockProducto, categoriaProducto)
values ('Salsa de Queso Cheddar',12690,32,'Lácteos'),
('Salchicha Perro Caliente',10900,15,'Embutidos'),
('Yogurt Frutos Rojos',3550,253,'Lácteos'),
('Butifarra',9733,252,'Emutidos');

insert into cliente_backup (nombreCliente, emailCliente)
select nombreCliente, emailCliente
from clientes
where creado_en<'2026-03-20';

# 1. Inserta 3 clientes nuevos con nombre, email y ciudad
insert into clientes (nombreCliente, emailCliente, ciudad)
values ("Emilio José", "emilio.jose@trabajomuyduro.com","Bogotá"),
("Efrain", "xxefragamer9000youtube@gmail.com","Turmequé"),
("Javier Shtiven", "elverdadero@elpropio.tv","Nobsa");

# 2. Inserta 2 productos con nombre, precio, stock y categoría
insert into productos (nombreProducto, precioProducto, stockProducto, categoriaProducto)
values ('Pechuga de Pollo Deshuesada',39355,564,'Pollo'),
('Gelatina de Pata',1969,45,'Delicias');

# 3. Inserta 1 pedido vinculando un cliente y un producto recién creados
insert into pedido (cantidadProducto, fechaPedido, idClienteFK, idProductoFK) values (4,'2026-03-21',3,2); # Pedro pedirá 4 Salchichas

# 4. Cambia la ciudad de uno de tus clientes insertados
update clientes set ciudad = 'Cajamarca' where idCliente = 2;

# 5. Aumenta en 5 unidades el stock de uno de tus productos
update productos set stockProducto = stockProducto + 5 where idProducto = 4;

# 6. Modifica el precio del segundo producto aplicando un descuento del 10%
update productos set precioProducto = precioProducto * 0.9 where idProducto = 2;

# 7. Elimina el pedido que creaste en el punto 3
delete from pedido where idPedido = 1;

# 8. Elimina el cliente cuya ciudad cambiaste en el punto 4
delete from clientes where idCliente = 2;

# 9. Elimina todos los productos con stock menor a 3
delete from productos where stockProducto < 3;

# Si no deja, descomentar esta línea:
# set sql_safe_updates = 0;
