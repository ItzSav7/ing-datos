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

/*Procedimientos almacenados aka Stored Procedures, funciones y vistas.
Procedimientos almacenados: Bloques de código de SQL con nombre. Se almacenan en el servidor, y se ejecutan con una invocación aka llamándolo (CALL).
	- De registro, creación, consulta, modificación/actualización o de eliminación
Funciones: Como en el back
Vistas: Consultas temporales que no se guardan. Salió a la disco a bailar una consulta virtual.
*/

/*Stores Procedures: Con parámetros
- De entrada (in): 
- De salida (out): 
- Ambas (inout): 
Sintaxis:
DELIMITER// 
CREATE PROCEDURE {nombre_procedimiento}(
	IN {parámetro_de_entrada} {tipo}
    OUT {parámetro_de_entrada} {tipo}
    INOUT {parámetro_de_entrada} {tipo}
)
BEGIN
{Declaración de variables locales}
DECLARE {variable} {tipo} DEFAULT {valor}

Cuerpo: {Sentencias SQL}

END //
DELIMITER;

Para invocar: 
CALL {nombreProcedimiento}({valor_in}, {valor_out},{variable_inout})*/
ALTER TABLE producto ADD stockProducto int null default 10;
ALTER TABLE pedido ADD estadoPedido varchar(20) null default 'Pendiente';
select * from producto;
# Registro de pedido completo, que modifica stock
DELIMITER //
CREATE PROCEDURE sp_crearPedido(
	IN p_idEmpleado int,
    IN p_idProducto int,
    IN p_cantidad int,
    out p_idPedido int,
    out p_mensaje varchar(50)
)
BEGIN
	DECLARE v_stock int;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN # Mensaje de error
			ROLLBACK;
            SET p_mensaje = 'Mal muy mal';
            SET p_idPedido = -1;
		END;
        SELECT stockProducto, precioProducto INTO v_stock, v_precio
        FROM productos WHERE id_producto = p_id_producto;
        IF v_stock < p_cantidad THEN
			SET p_mensaje=CONCAT('Never enough money in da bank. Hay: ',v_stock);
			SET p_idPedido = 0;
		ELSE
			START TRANSACTION;
			SET v_total = v_precio * p_cantidad;
			INSERT INTO pedido(idEmpleadoFK, total) VALUES (p_idEmpleado, v_total); # Crear Pedido
			SET p_idPedido = LAST_INSERT_ID();
			insert into detallePedido(idPedidoFK, idProductoFK, cantidad, precioUnit) VALUES (p_idPedido, p_idProducto, p_cantidad, v_precio); # Crear detalle
			update producto # Descontar del stock
			set stockProducto = stock - p_cantidad
			where idProducto = p_id_producto;
			COMMIT;
			SET p_mensaje=CONCAT('Pedido #',p_idPedido,' acido');
		END IF;
	
END //
DELIMITER ;
select * from pedido;
select @pedido_id as id_pedido, @msg as mensaje;
drop procedure sp_crearPedido;
# invocar al diablo loco
CALL sp_crearPedido(1, 3, 2, @pedido_id,@msg);

# TAREA: Investigar y hacer un ejemplo de un procedimiento con Cursor

# Crear un procedimiento almacenado que permita cancelar un pedido
# Debe recibir el idPedido y el idEmpleado (para válidar que el pedido pertenezca al cliente)
# Si no existe, mostrar mensaje de error
# Validar que el pedido no esté 'cancelado' ni 'entregado', solo se va a poder cancelar pedidos que esten 'pendientes' o 'enviados'.
# Actualizar el estado a 'cancelado'
# Restaurar el stock (revertir la reserva) de cada producto de ese pedido (usando inner join detalle pedido, update por cada producto del pedido)
# Retornar como parámetro de salida un mensaje que diga algo como "pedido #x cancelado. restaurado para n productos" or sum, a menos de que no, entonces mismo mensaje error (no existe o no pertenece al empleado)
describe pedido;
DELIMITER //
CREATE PROCEDURE sp_cancelarPedido(
	IN p_idPedido int,
    IN p_idEmpleado int,
    out p_mensaje varchar(50)
)
BEGIN
	DECLARE v_estado int;
    DECLARE v_idEmpleado int;
    DECLARE v_idPedido int;
    DECLARE v_numProductos int;
    
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN # Mensaje de error
			ROLLBACK;
            SET p_mensaje = 'Pailonguis';
		END;
        /*SELECT idPedido, idEmpleadoFK INTO v_idEmpleado, v_idPedido
        FROM pedido WHERE idPedido = p_idPedido;*/
        
        select estado, idEmpleado into v_estado, v_idEmpleado
        from pedido where idPedido = p_idPedido;
        
        IF v_idEmpleado IS NULL THEN
			SET p_mensaje=CONCAT('No existe :(');
		ELSEIF v_idEmpleado <> p_idEmpleado THEN
			SET p_mensaje=CONCAT('No existe para este empleado im sorry');
		ELSEIF v_estado IN ('Cancelado','Entregado') THEN
			SET p_mensaje=CONCAT('No se puede cancelar este tipo de pedidos D:');
		ELSE
            START TRANSACTION;
            UPDATE productos pr
            INNER JOIN detallepedido dp ON pr.idProducto = dp.idProductoFK
            SET pr.stockProducto = pr.stockProducto + dp.cantidad
            where dp.idPedidoFK = p_idPedido;
			
            select count(*) into v_numProductos
            from detallepedido
            where idPedidoFK = p_id_pedido;
            
            UPDATE pedido
            set estado = 'Cancelado'
            where idPedido = p_idPedido;
            
			COMMIT;
			SET p_mensaje=CONCAT('Pedido #',p_idPedido,' fue cancelado. Stock se reestablece para ', v_numProductos, ' productos.');
		END IF;
	
END //
DELIMITER ;

CALL sp_cancelarPedido(1,1, @msg);

select @pedido_id as id_pedido, @msg as mensaje;

# TAREA 2: Convertir ambos procedimientos en una vista (solo son para consultas)