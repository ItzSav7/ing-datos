/*
---------------------------------
RETOS!! CLASE 18/03/2026
Autor: Santiago Velandia

Notas:
- El tercer reto (crear FK entre clientes y productos) 
  lo gané yo ojo, nadie mas ojo, el propio

(Dejo también constancia de que el primero lo ganó Laura, el segundo Juan Esteban y el cuarto Victoria)
---------------------------------
*/

# Reto 1
create database tienda_online;
use tienda_online;

# Reto 2
create table productos(
idProducto int auto_increment primary key,
nombreProducto varchar(20) not null,
precioProducto double not null,
stock int null default 0,
fechaCreacion datetime not null default current_timestamp
);

# Reto 3
create table clientes(
idCliente int auto_increment primary key,
nombreCliente varchar(50) not null,
emailCliente varchar(50) unique not null,
telefonoCliente int null
);

create table pedidos(
idPedido int auto_increment primary key,
idClienteFK int not null,
fecha date not null,
total double not null
);

alter table pedidos
add constraint fkclientespedidos
foreign key (idClienteFK)
references clientes(idCliente);

# Reto 4
alter table productos add categoriaProducto varchar (50) null;
alter table clientes modify telefonoCliente varchar(15) null;
alter table pedidos change total monto_Total double;
alter table productos drop fechaCreacion;