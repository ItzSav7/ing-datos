# Autor: Santiago Velandia
# Versión 2. Actualización el 07 de abril para añadir las consultas de la tarea.

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

# select * from empleados;

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

# Ok no estoy seguro si la idea era mostrar los productos cuyo precio fuera mayor al promedio total o al promedio de su categoria... así que hice las dos?? creo

# En general
select nombreProducto, precioProducto, categoriaProducto
from producto
where precioProducto > 
    (select AVG(precioProducto) from producto)
order by precioProducto DESC;

# Por categoría aunque creo que esta no funciona bien :/
select nombreProducto, precioProducto, categoriaProducto, promedioCategoria
from 
  (select nombreProducto, precioProducto, categoriaProducto, promedioCategoria
  from (select nombreProducto, precioProducto, categoriaProducto, avg(precioProducto) as promedioCategoria 
        from producto 
        group by categoriaproducto))
group by categoriaproducto
having precioproducto >= promedioCategoria
order by precioproducto DESC;
