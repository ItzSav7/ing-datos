/*-----------------------------------
Autor: Santiago Velandia
Versión 4. 
Actualización el 09 de abril para añadir las consultas multitabla de la tarea.
Este script también funciona como notas de clase que tomo.
-----------------------------------*/

/*Los más plays de bases de datos - SubQuerys

select {col1,col2,..,coln}
from {tabla_principal}
where {condición}
	select {col1,col2,..,coln}
    from {tabla_secundaria}
    where {condición};

Tipos:
- Escalares: Devuelve un único valor - fila o columna. [Usualmente -> Operadores de comparación, <, >, =]
- De Fila: Devuelve una sola fila con varias columnas. [Usualmente -> row() o comparaciones de tuplas]
- De Tabla: Devuelve una tabla - varios registros con varios campos. [Usualmente -> Cláusula from]
- Correlacionales: Referencia columnas de otra tabla mediante una FK.
*/

# Reto 1

create database if not exists db_empleados;

use db_empleados;

create table empleados(
	idEmpleado int primary key auto_increment,
    nombreEmpleado varchar(50) not null,
    idDeptoFK int,
    foreign key (idDeptoFK) references departamento (idDepto),
    salarioEmpleado double not null
);

create table producto(
	idProducto int primary key auto_increment,
    nombreProducto varchar(50) not null,
    precioProducto double not null,
    categoriaProducto varchar(30) not null
);

create table departamento(
	idDepto int primary key auto_increment,
    nombreDepto varchar(50) not null
);

# Reto 2

insert into departamento (nombreDepto) values ('Limpieza'), ('Tesorería'), ('Legal');
insert into empleados (nombreEmpleado, idDeptoFK, salarioEmpleado) values ('Sara Martínez', 2, 1750905),
('Maria José Árias', 3, 1750905),
('Samuel Fierro', 1, 875452),
('Juan Sebastián Ospina',2,3501810),
('Elizabeth Almeida',3,3501810);

insert into producto (nombreProducto, precioProducto, categoriaProducto) values ('Trapero', 5300, 'Limpieza'),
('Recogedor', 7100, 'Limpieza'),
('Galletas', 76406, 'Dulces'),
('Pasta de Tomate', 8800, 'Condimentos'),
('Pilas AA', 24900, 'Varios');

insert into producto (nombreProducto, precioProducto, categoriaProducto) values ('Cable Unifilar',5000000, 'Carnes');

/*Practicando SubConsultas*/

# Consultar los salarios que sean mayores al promedio
# Solo usando 'where'
select nombreEmpleado, salarioEmpleado
from empleados
where salarioEmpleado >
	(select AVG(salarioEmpleado)
    from empleados);

# Usando 'where' e 'in'
select nombreEmpleado, salarioEmpleado
from empleados
where idDeptoFK in
	(select idDepto
    from departamento
    where nombreDepto in ('Legal', 'Tesorería'));
    
# Tabla derivada - Salió a la disco a bailar una tabla virtual
# Es la tabla que se deriva de una consulta
select idDeptoFK, prom_salario
from 
	(select idDeptoFK, avg(salarioEmpleado) as prom_salario
	from empleados
    group by idDeptoFK) as promedios # Se crea una tabla promedios de la consulta del promedio de salarios de la tabla departamento
where prom_salario > 900000; # Se usa esa tabla derivada para solo mostrar algunos

# Consulta toda rara anidada
# Ya debería estar arreglada
select nombreEmpleado, salarioEmpleado, prom_salario, diferencia
from
	(select nombreEmpleado, salarioEmpleado, prom_salario, abs(salarioEmpleado - prom_salario) as diferencia
    from 
		(select nombreEmpleado, salarioEmpleado, (select avg(salarioEmpleado) from empleados) as prom_salario
		from empleados) as promedio_general
    ) as diferencia_salario;
    
# Subconsulta que muestre la categoría de los productos y los precios máximos de los productos
# Pero va a mostrar el producto cuyo precio sea mayor que el promedio
# Organizado por precio
select nombreProducto, precioProducto, categoriaProducto
from producto
where precioProducto > 
    (select AVG(precioProducto) from producto)
order by precioProducto DESC;

select * from producto;

# 08 de abril
create table pedido(
	idPedido int primary key auto_increment,
    fechaPedido datetime default now(),
    idEmpleadoFK int,
    foreign key (idEmpleadoFK) references empleados(idEmpleado)
);

create table detallePedido(
	idDetalle int primary key auto_increment,
    idProductoFK int,
    idPedidoFK int,
    foreign key (idProductoFK) references producto(idProducto),
    foreign key (idPedidoFK) references pedido(idPedido)
);
/* JOINS - Uniones entre tablas, sin necesidad de que esten relacionadas
Tipos de Join:
	- LEFT: Todas las filas de la tabla izquierda y las que tienen coincidencia con las de la derecha.
    - RIGHT: Todas las filas de la tabla derecha y las que tienen coincidencia con las de la izquierda.
    - INNER: Solo las comunes. Algo como una intersección.
    - CROSS: Producto cartesiano. Todas las posibles combinaciones entre las filas de dos tablas.
    - SELF: Se hace las consultas consigo mismo. Casi como una subquery.
*/
select * from detallepedido;
insert into pedido (idEmpleadoFK) values (3),(2),(1),(2),(4),(4);
insert into detallepedido (idPedidoFK, idProductoFK) values (2, 1),(3,2),(1,1),(5,5),(6,4),(3,3);

select p.idPedido, e.nombreEmpleado as cliente, p.fechaPedido
from pedido p # tabla de la izquierda
inner join empleados e on p.idEmpleadoFK = e.idEmpleado # tabla de la derecha
order by p.fechaPedido desc;

select e.idEmpleado, count(p.idPedido) as totalPedidos,e.nombreEmpleado as cliente, p.fechaPedido
from empleados e # tabla de la izquierda
left join pedido p on e.idEmpleado = p.idEmpleadoFK # tabla de la derecha
order by p.fechaPedido desc;

select * from pedido;

/* TAREA: Mostrar el detalle completo de los pedidos: empleado, que pedidos tiene, que productos tiene el pedido.
(Solo los que tengan pedido).
(Algo raro tendré que hacer con detallePedido pero i'll figure it out)*/
select 	e.nombreEmpleado as Empleado,
		p.idPedido as Pedido,
		p.fechaPedido as Fecha,
		pr.nombreProducto as Producto,
		pr.precioProducto as Precio
from empleados e
inner join pedido p on e.idEmpleado = p.idEmpleadoFK
inner join detallepedido dp on p.idPedido = dp.idPedidoFK
inner join producto pr on dp.idProductoFK = pr.idProducto
order by e.idEmpleado asc, p.idPedido asc;
