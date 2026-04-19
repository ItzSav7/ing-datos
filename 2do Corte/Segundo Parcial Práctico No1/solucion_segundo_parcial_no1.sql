-- ===================================================== 
-- DDL: CREACION DE BASE DE DATOS Y TABLAS 
-- ===================================================== 

# DROP DATABASE IF EXISTS tienda_tech; 
CREATE DATABASE tienda_tech CHARACTER SET utf8mb4; 
USE tienda_tech; 

CREATE TABLE clientes ( 
    cliente_id      INT AUTO_INCREMENT PRIMARY KEY, 
    nombre          VARCHAR(100) NOT NULL, 
    email           VARCHAR(100) UNIQUE NOT NULL, 
    ciudad          VARCHAR(60), 
    fecha_registro  DATE DEFAULT (CURRENT_DATE) 
); 

CREATE TABLE productos ( 
    producto_id  INT AUTO_INCREMENT PRIMARY KEY, 
    nombre       VARCHAR(100) NOT NULL, 
    categoria    VARCHAR(60), 
    precio       DECIMAL(10,2) NOT NULL CHECK (precio > 0), 
    stock        INT DEFAULT 0 
); 

CREATE TABLE pedidos ( 
    pedido_id    INT AUTO_INCREMENT PRIMARY KEY, 
    cliente_id   INT NOT NULL, 
    producto_id  INT NOT NULL, 
    cantidad     INT NOT NULL CHECK (cantidad > 0), 
    fecha_pedido DATE DEFAULT (CURRENT_DATE), 
    estado       VARCHAR(20) DEFAULT "pendiente" 
        CHECK (estado IN ("pendiente","entregado","cancelado")), 
    FOREIGN KEY (cliente_id)  REFERENCES clientes(cliente_id), 
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id) 
); 

-- ===================================================== 
-- DML: DATOS DE PRUEBA 
-- ===================================================== 

INSERT INTO clientes VALUES 
 (1,"Ana Lopez","ana@mail.com","Bogota","2023-01-15"), 
 (2,"Carlos Ruiz","carlos@mail.com","Medellin","2023-03-22"), 
 (3,"Maria Torres","maria@mail.com","Cali","2023-05-10"), 
 (4,"Pedro Gomez","pedro@mail.com","Bogota","2023-07-08"), 
 (5,"Sofia Herrera","sofia@mail.com","Barranquilla","2023-09-01"), 
 (6,"Luis Martinez","luis@mail.com","Bogota","2024-01-20"), 
 (7,"Camila Vargas","camila@mail.com","Cali","2024-02-14"), 
 (8,"Diego Morales","diego@mail.com","Medellin","2024-03-30"); 

INSERT INTO productos VALUES 
 (1,"Laptop Pro 15","Computadores",3500000.00,12), 
 (2,"Mouse Inalambrico","Perifericos",85000.00,50), 
 (3,"Teclado Mecanico","Perifericos",220000.00,30), 
 (4,"Monitor 27","Pantallas",1200000.00,8), 
 (5,"Auriculares BT","Audio",350000.00,25),
 (6,"Webcam HD","Perifericos",180000.00,20), 
 (7,"Disco SSD 1TB","Almacenamiento",420000.00,40), 
 (8,"Tablet 10","Moviles",1800000.00,6); 

INSERT INTO pedidos VALUES 
 (1,1,1,1,"2024-01-10","entregado"),(2,1,2,2,"2024-01-15","entregado"), 
 (3,2,3,1,"2024-02-05","entregado"),(4,2,5,1,"2024-02-20","cancelado"), 
 (5,3,4,1,"2024-03-01","entregado"),(6,3,7,2,"2024-03-15","pendiente"), 
 (7,4,2,3,"2024-04-02","entregado"),(8,4,6,1,"2024-04-10","pendiente"), 
 (9,5,8,1,"2024-04-18","entregado"),(10,6,1,2,"2024-05-05","entregado"), 
 (11,6,3,1,"2024-05-12","pendiente"),(12,7,5,2,"2024-05-20","entregado"), 
 (13,1,7,1,"2024-06-01","entregado"),(14,8,4,1,"2024-06-10","cancelado"), 
 (15,5,2,4,"2024-06-15","entregado"),(16,3,1,1,"2024-07-01","pendiente"); 
 
 # SET SQL_SAFE_UPDATES = 0;
 /*1. Agregue a la tabla pedidos una columna total_valor DECIMAL(12,2) generada automáticamente como la multiplicacion de cantidad por el precio del producto 
 (columna calculada persistida con AS ... STORED, o en su defecto agréguela como columna normal y luego actualice su valor mediante un UPDATE con JOIN entre 
 pedidos y productos). Finalmente, agregue un índice sobre la columna estado.
 Clausulas requeridas: ALTER TABLE, UPDATE ... JOIN, CREATE INDEX */
 # La cláusula GENERATED ALWAYS AS ... STORED no permite sacar valores de otras tablas. Haré la segunda opción...
 
ALTER TABLE pedidos ADD total_valor DECIMAL(12,2);

UPDATE pedidos pe 
INNER JOIN productos p ON p.producto_id = pe.producto_id # Acá si lo hace fila por fila.
SET pe.total_valor = pe.cantidad * p.precio;

CREATE INDEX index_estado
ON pedidos (estado);

/*2. Cree la tabla log_cambios_estado (log_id PK AI, pedido_id FK, estado_anterior VARCHAR(20), estado_nuevo VARCHAR(20), fecha_cambio DATETIME DEFAULT NOW()). 
A continuación, cree una vista llamada vista_log_reciente que muestre los últimos 10 registros de log_cambios_estado ordenados por fecha_cambio descendente. 
Clausula requeridas: CREATE TABLE, FOREIGN KEY, CREATE VIEW, ORDER BY, LIMIT */
create table log_cambios_estado(
	log_id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT,
    estado_anterior VARCHAR(20),
    estado_nuevo VARCHAR(20),
    fecha_cambio DATETIME DEFAULT NOW(),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id)
);

CREATE VIEW vista_log_reciente AS
SELECT * FROM log_cambios_estado
ORDER BY fecha_cambio DESC
LIMIT 10;

/*3. Realice las siguientes operaciones en una misma sesión:
(a) Inserte un nuevo cliente (nombre=Laura Rios, email=laura@mail.com, ciudad=Manizales).
(b) Inserte un pedido para ese cliente del producto_id=3 con cantidad=2 y estado=pendiente.
(c) Actualice el stock del producto_id=3 decrementandolo en 2.
(d) Consulte con un JOIN el nombre del cliente, nombre del producto y estado del pedido recién creado.*/

INSERT INTO clientes (nombre, email, ciudad) VALUES ('Laura Rios', 'laura@mail.com', 'Manizales');
INSERT INTO pedidos (cliente_id, producto_id, cantidad, estado) VALUES (LAST_INSERT_ID(), 3,2,'pendiente'); # IMPORANTE: LAST_INSERT_ID con la linea 110 es 9, pero con esta, se vuelve 17.
UPDATE productos SET stock = stock - 2 WHERE producto_id = 3;
SELECT c.nombre, pr.nombre, p.estado
FROM clientes c 
INNER JOIN pedidos p ON c.cliente_id = p.cliente_id
INNER JOIN productos pr ON p.producto_id = pr.producto_id
WHERE c.cliente_id = 9;

/*4. Actualice el precio de todos los productos cuyo stock sea menor al promedio de stock de su misma categoría (use subconsulta correlacionada), 
incrementando el precio un 8%. Luego elimine los pedidos con estado cancelado cuyos clientes no tengan ningún otro pedido en estado entregado (use subconsulta con NOT EXISTS).
Clausulas requeridas: UPDATE con subconsulta correlacionada, DELETE con NOT EXISTS */

UPDATE productos
SET precio = precio * 1.08
WHERE stock < (
	SELECT ROUND(AVG(stock)) from productos pr
    WHERE categoria = pr.categoria);

DELETE FROM pedidos
WHERE estado = 'cancelado' AND 
NOT EXISTS (SELECT * FROM pedidos p2 WHERE pedidos.cliente_id = p2.cliente_id AND p2.estado = 'entregado');

/*5. Liste el nombre del cliente, ciudad, nombre del producto, cantidad y fecha_pedido de todos los pedidos entregados cuyo total (cantidad * precio) supere el promedio
general de totales de pedidos entregados. Ordene los resultados por total descendente. 

Clausulas requeridas: JOIN tres tablas, WHERE con subconsulta escalar AVG, ORDER BY DESC */

SELECT c.nombre, c.ciudad, pr.nombre, p.cantidad, p.fecha_pedido
FROM clientes c
INNER JOIN pedidos p ON c.cliente_id = p.cliente_id
INNER JOIN productos pr ON pr.producto_id = p.producto_id
WHERE (p.cantidad * pr.precio) >=
	(SELECT AVG(p.cantidad * pr.precio) FROM pedidos p
    INNER JOIN productos pr ON pr.producto_id = p.producto_id)
ORDER BY (p.cantidad * pr.precio) DESC;

/*6. Cree la vista vista_ventas_ciudad que muestre: ciudad, total_pedidos_entregados, suma_ingresos (SUM de cantidad*precio) y promedio_ingreso_por_pedido.
Luego consulte la vista para mostrar solo las ciudades cuyo suma_ingresos supere los 5,000,000, ordenadas de mayor a menor. 
Clausula requeridas: CREATE VIEW con JOIN, GROUP BY, CREATE INDEX opcional, SELECT FROM vista con WHERE y ORDER BY */
CREATE VIEW vista_ventas_ciudad AS
SELECT 
c.ciudad,
COUNT(p.pedido_id) as total_pedidos_entregados,
SUM(p.cantidad * pr.precio) as suma_ingresos,
ROUND(AVG(p.cantidad * pr.precio),2) as promedio_ingreso_por_pedido
FROM clientes c
INNER JOIN pedidos p ON c.cliente_id = p.cliente_id
INNER JOIN productos pr ON p.producto_id = pr.producto_id
GROUP BY c.ciudad;

SELECT * from vista_ventas_ciudad WHERE suma_ingresos >= 5000000 ORDER BY suma_ingresos DESC;

/*7. Cree la vista vista_productos_populares que liste los productos que hayan sido pedidos por más de un cliente distinto (en pedidos entregados).
La vista debe mostrar: producto_id, nombre, categoria, precio y total_clientes_distintos.
Luego use la vista para obtener unicamente los productos de la categoría Perifericos. 

Clausula requeridas: CREATE VIEW con subconsulta o HAVING COUNT(DISTINCT), SELECT FROM vista con WHERE */

CREATE VIEW vista_productos_populares AS
SELECT p.producto_id, pr.nombre, pr.categoria, pr.precio, (COUNT(DISTINCT(cliente_id))) as total_clientes_distintos from pedidos p
INNER JOIN productos pr ON p.producto_id = pr.producto_id
WHERE p.estado = "entregado"
GROUP BY producto_id
HAVING total_clientes_distintos > 1;

SELECT * FROM vista_productos_populares WHERE categoria = "Perifericos";

/*8. Cree la función fn_ingreso_cliente(p_cliente_id INT) que retorne el ingreso total acumulado de un cliente 
(suma de cantidad*precio solo para pedidos entregados, usando JOIN entre pedidos y productos). 
Luego use esa función en un SELECT sobre la tabla clientes para mostrar nombre, ciudad y su ingreso_total, ordenados de mayor a menor ingreso. 
Clausulas requeridas: CREATE FUNCTION con SELECT JOIN, RETURN; SELECT usando la función en la lista de columnas */

DELIMITER //
CREATE FUNCTION fn_ingreso_cliente(
	p_cliente_id INT
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
	DECLARE v_ingreso_total_cliente DECIMAL(12,2) DEFAULT 0;
    
    SELECT SUM(p.cantidad * pr.precio) INTO v_ingreso_total_cliente
    FROM pedidos p
    INNER JOIN productos pr ON p.producto_id = pr.producto_id
    WHERE p.estado = "entregado" AND p.cliente_id = p_cliente_id;

	RETURN v_ingreso_total_cliente;
END //
DELIMITER ;

SELECT nombre, ciudad, fn_ingreso_cliente(cliente_id) as ingreso_total
FROM clientes
ORDER BY ingreso_total DESC;

/*9. Cree la función fn_stock_suficiente(p_producto_id INT, p_cantidad_solicitada INT)
que retorne 1 si el stock actual del producto es mayor o igual a la cantidad solicitada, o 0 en caso contrario. 
Luego escriba una consulta que liste nombre y stock de todos los productos donde fn_stock_suficiente(producto_id, 5) = 0, 
es decir, productos con menos de 5 unidades disponibles. 
Clausulas requeridas: CREATE FUNCTION, SELECT con WHERE usando la función, subconsulta o logica equivalente */

DELIMITER //
CREATE FUNCTION fn_stock_suficiente(
	p_producto_id INT,
    p_cantidad_solicitada INT
)
RETURNS BOOL
DETERMINISTIC
READS SQL DATA
BEGIN
	DECLARE v_stock_actual INT;
    
    SELECT stock INTO v_stock_actual
    FROM productos
    WHERE producto_id = p_producto_id;
    
    IF (v_stock_actual >= p_cantidad_solicitada) THEN
		RETURN 1;
	ELSE
		RETURN 0;
	END IF;
END //
DELIMITER ;

SELECT nombre, stock FROM productos WHERE fn_stock_suficiente(producto_id, 5) = 0;
