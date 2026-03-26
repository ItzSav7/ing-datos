/*
-----------------------------------------------------
Autor:         	Santiago Velandia
Fecha:         	2026-Mar-26

Base de datos: tiendaOnline

Notas:
- Basado en el script hecho en clase. No todos los ejemplos son idénticos a los hechos en clase.
- Contiene las líneas de las tareas anteriores
- Lo nuevo está al final final
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
# -----------------------------------------------------------------------------------
# Consulta general
select * from productos;

# Cambiar a stoProdT
alter table productos change stockProducto stoProdT int; 

# Consulta específica - alias
select nombreProducto as 'Nombre', stoProdT as 'Stock' from productos;

# Consulta específica - where
select nombreProducto as 'Nombre', stoProdT as 'Stock' from productos where stoProdT >20 AND categoriaProducto = 'Lácteos';

select nombreProducto as 'Nombre', stoProdT as 'Stock' from productos where stoProdT >= 25 OR idProducto = 1;

# Consulta ordenada Ordenadas
select nombreProducto as 'Nombre', stoProdT as 'Stock' 
from productos order by nombreProducto ASC;

select nombreProducto as 'Nombre', stoProdT as 'Stock' 
from productos order by stoProdT DESC;

/*Cláusula BETWEEN - Entre rangos: {valor1} AND {valor2}*/
select nombreProducto as 'Nombre', precioProducto as 'Precio' 
from productos where precioProducto between 500 and 10000 and stoProdT > 20 order by precioProducto ASC;

# Prefijo
select * from productos where nombreProducto like 'p%';

# Subcadena
select * from productos where nombreProducto like '%a%';
 
# Sufijo
select * from productos where nombreProducto like '%e';

# Cláusula limit x - Solo muestra x resultados

describe pedidos;
select * from productos;

/*Cargar 50 registros de un csv a las tablas

LOS CARGUÉ CON EL WIZARD. LOS CARGUÉ CON EL WIZARD. LOS CARGUÉ CON EL WIZARD. LOS CARGUÉ CON EL WIZARD. LOS CARGUÉ CON EL WIZARD.*/

# Clientes - LA SENTENCIA NO ME SIRVIÓ POR TEMA DE PERMISOS QUE NO PUDE RESOLVER
/*load data local infile '/registrosClientes.csv'
into table clientes
fields terminated by ','
lines terminated by '\n'
ignore 1 rows # el header
(nombreCliente, emailCliente, ciudad);*/

/*Consultas usando métodos númericos o de caracter.*/

# Métodos caracter
select upper(nombreProducto) as Nombre, precioProducto as Precio 
from productos 
limit 15;

select nombreCliente as Nombre, emailCliente as Email, ciudad as Ciudad
from clientes where length(ciudad) < 6 and emailCliente not like '.com%'
order by ciudad ASC;

# Métodos numéricos
select nombreProducto as Nombre, precioProducto as Precio 
from productos where precioProducto between ln(precioProducto) * 1000 and 10000 * pi()
order by precioProducto DESC limit 10;

select nombreCliente as Nombre, emailCliente as Email, ciudad as Ciudad
from clientes where (sqrt(ascii(emailCliente)) + ln(ascii(nombreCliente)) * pi()) > 20 and emailCliente like '%la%'
limit 8;

/*Clase del 26 de Marzo*/
update productos set nombreProducto = 'Galletas Que Hacia Mi Amigo Sebastian En Noveno Y El Resto De La Prom Lo Llamaba El Bro Galleta' where idProducto = 9;
# Mientras hago importaciones... Para tablas que tienen FK pero aun puede que no esten creadas las otras tablas...
set foreign_key_checks=0;

select * from productos;
 /*Consultas específicas v2
 Cláusula GROUP BY - 
 */

select * from productos group by categoriaProducto;
select * from productos order by categoriaProducto ASC;

/*Funciones calculadas y HAVING -> Filtro de agrupaciones */
select categoriaProducto as 'Categoria', 
count(*) as 'Cantidad', # Cuenta cuantos productos hay por categoria
round(avg(precioProducto)) as precioMedio # Sale es el promedio del precio de la categoria
from productos 
group by categoriaProducto
having avg(precioProducto) > 5000
order by precioMedio;

# Para ver los númeritos más bonitos (1.000.000,00 en ves de 1000000.00)
select format (precioProducto,2,'es_CO') as precio from productos;

# Funciones agregadas
select
count(*) as Total,
truncate(avg(precioProducto),2) as PromedioPrecio,
max(precioProducto) as PrecioMaximo,
min(precioProducto) as PrecioMinimo,
sum(stoProdT) as StockTotal
from productos;

# Ejemplo usando funciones para alfanuméricas
select concat(nombreCliente,' aka ',emailCliente) as 'Concatenación nombre con email',
UPPER(nombreCliente) as 'NOMBRE PERO GRITADO', 
concat(UPPER(nombreCliente),' i cant do this anymore ',emailCliente) as 'Concatenación NOMBRE con email',
length(nombreCliente) as 'Tamaño Nombre'
from clientes;

/*SUBCONSULTAS - Anidadas*/
# Ej: Consultar los clientes que realizaron 2 pedidos de un producto cuyo precio sea mayor a 100000
# Es subconsulta, se consulta solo la tabla pedidos, que tiene FK hacia clientes y productos.


