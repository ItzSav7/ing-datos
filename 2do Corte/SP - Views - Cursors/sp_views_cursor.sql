/*
Script: sp_views_cursor.sql
Autor: Santiago Velandia (basado en el script hecho en clase)
Nota: 
- Todos los nombres de las tablas están en singular
- Por lo tanto, los nombres de las tablas en este script pueden ser diferentes al que la profe hizo y subió al e-aulas
*/

CREATE DATABASE IF NOT EXISTS nueva_tienda_online;
USE nueva_tienda_online;

CREATE TABLE categoria (
    idCategoria INT AUTO_INCREMENT PRIMARY KEY,
    nombreCategoria VARCHAR(80) NOT NULL,
    descripcionCategoria TEXT
);
 
CREATE TABLE producto (
    idProducto INT AUTO_INCREMENT PRIMARY KEY,
    nombreProducto VARCHAR(120) NOT NULL,
    precioProducto DECIMAL(10,2) NOT NULL,
    stockProducto INT DEFAULT 0,
    idCategoriaFK INT,
    FOREIGN KEY (idCategoriaFK) REFERENCES categoria(idCategoria)
);
 
CREATE TABLE cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    nombreCliente VARCHAR(100) NOT NULL,
    emailCliente VARCHAR(150) UNIQUE NOT NULL,
    ciudadCliente VARCHAR(80),
    fechaRegistroCliente DATE DEFAULT NOW()
);
 
CREATE TABLE pedido (
    idPedido INT AUTO_INCREMENT PRIMARY KEY,
    idClienteFK INT NOT NULL,
    fechaPedido DATETIME DEFAULT NOW(),
    estadoPedido ENUM('pendiente','enviado','entregado','cancelado') DEFAULT 'pendiente', # ENUM es como si fuera un dropdown menu
    totalPedido DECIMAL(12,2) DEFAULT 0,
    FOREIGN KEY (idClienteFK) REFERENCES cliente(idCliente)
);
 
CREATE TABLE detalle_pedido (
    idDetalle INT AUTO_INCREMENT PRIMARY KEY,
    idPedidoFK INT NOT NULL,
    idProductoFK INT NOT NULL,
    cantidad INT NOT NULL,
    precioUnit DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (idPedidoFK) REFERENCES pedido(idPedido),
    FOREIGN KEY (idProductoFK) REFERENCES producto(idProducto)
);
 
# Inserción de datos random - basados en Ortizo pq why not
INSERT INTO categoria (nombreCategoria, descripcionCategoria) VALUES ('Cuerdas','Instrumentos de cuerda varios'),
    ('Teclados','Pianos, organetas y sintetizadores'),('Baterías','Acústicas, electrónicas y partes por separado'),('Percusión','Instrumentos de percusión varios');
 
INSERT INTO producto (nombreProducto, precioProducto, stockProducto, idCategoriaFK) VALUES
    ('Fender Squier Debut Stratocaster Sunburst',799900.00,15,1),('Kalani Soprano Uk-21',112900.00,40,1),
    ('Arranger Roland E-X50',2362900.00,100,2),('Alesis Nitromax Kit XUS',2359000.00,30,3),('Tycoon Ralph Irizarry 14"','2179900.00',25,4);
 
INSERT INTO cliente (nombreCliente, emailCliente, ciudadCliente, fechaRegistroCliente) VALUES
    ('Ana García','ana@email.com','CDMX','2024-01-10'),
    ('Luis Pérez','luis@email.com','GDL','2024-02-15'),
    ('María López','maria@email.com','MTY','2024-03-01');
 
INSERT INTO pedido (idClienteFK, fechaPedido, estadoPedido, totalPedido) VALUES
    (1,NOW(),'entregado',912800.00),(2,NOW(),'enviado',112900.00),
    (1,NOW(),'pendiente',7084800.00),(3,NOW(),'cancelado',2179900.00);
 
INSERT INTO detalle_pedido VALUES # idDetalle, pedido, producto, cantidad, precioUnit
    (1,1,1,1,799900.00),(2,1,2,1,112900.00),
    (3,2,2,1,112900.00),(4,3,3,2,4725800.00),(5,3,4,1,2359000.00),(6,4,5,1,2179900.00);

#Pedidos con el nombre del cliente
select p.idPedido, 
c.nombreCliente as cliente,
c.idCliente,
c.ciudadCliente,
p.fechaPedido,
p.estadoPedido,
p.totalPedido
from pedido p
inner join cliente c on p.idClienteFK=c.idCliente
order by p.fechaPedido desc;

# clientes que aun no tengan pedidos
# esto solo cuenta la cantidad de pedidos lmao
select 
c.nombreCliente as cliente,
c.idCliente,
c.ciudadCliente,
count(p.idPedido) as totalPedido
from cliente c
left join pedido p on c.idCliente=p.idClienteFK
order by p.fechaPedido desc;

# Detalle completo de un pedido: Cliente - Pedido - Detalle - Producto
select
c.nombreCliente as Cliente,
p.idPedido,
p.estadoPedido,
pr.nombreProducto as Producto,
ca.nombreCategoria as Categoria,
dp.cantidad as Cantidad,
dp.precioUnit,
(dp.cantidad*dp.precioUnit) as Subtotal
from cliente c
inner join pedido p on c.idCliente=p.idClienteFK
inner join detalle_pedido dp on p.idPedido=dp.idPedidoFK
inner join producto pr on dp.idProductoFK=pr.idProducto
inner join categoria ca on pr.idCategoriaFK = ca.idCategoria
order by c.nombreCliente, p.idPedido;

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

# SP1: Registrar un pedido
DELIMITER //
CREATE PROCEDURE spCrearPedido(
    IN  p_idCliente  INT, # a quien
    IN  p_idProducto INT, # que
    IN  p_cantidad    INT, # cuanto
    OUT p_idPedido   INT, # el pedido que se crea
    OUT p_mensaje     VARCHAR(200) # debug
)
BEGIN
    DECLARE v_stock   INT; # se contectará con stockProducto FROM producto
    DECLARE v_precio  DECIMAL(10,2); # se conectará con precioProducto FROM producto
    DECLARE v_total   DECIMAL(12,2); # se conectarácon totalPedido FROM pedido
 
    -- Manejador de errores: si algo falla, hace ROLLBACK
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensaje = 'Error detectado: transacción revertida';
        SET p_idPedido = -1; # placeholder
    END;
 
    -- Validar stock disponible
    SELECT stockProducto, precioProducto INTO v_stock, v_precio
    FROM producto WHERE idProducto = p_idProducto; # Seleccionar el producto que entró como parámetro
 
    IF v_stock < p_cantidad THEN
        SET p_mensaje  = CONCAT('Stock insuficiente. Disponible: ', v_stock);
        SET p_idPedido = 0;
    ELSE
        START TRANSACTION;
 
        SET v_total = v_precio * p_cantidad;
 
        -- Crear cabecera del pedido [relación cliente - pedido]
        INSERT INTO pedido(idClienteFK, totalPedido)
        VALUES (p_idCliente, v_total);
        SET p_idPedido = LAST_INSERT_ID(); # El propio 'pongalo al final'
 
        -- Insertar detalle [relacion pedido - producto]
        INSERT INTO detalle_pedido(idPedidoFK, idProductoFK, cantidad, precioUnit)
        VALUES (p_idPedido, p_idProducto, p_cantidad, v_precio);
 
        -- Descontar stock
        UPDATE producto
        SET stockProducto = stockProducto - p_cantidad
        WHERE idProducto = p_idProducto;
 
        COMMIT;
        SET p_mensaje = CONCAT('Pedido #', p_idPedido, ' creado correctamente :)');
    END IF;
END //
DELIMITER ;

# CALL al SP
CALL spCrearPedido(3,3,2,@pedido_id,@msg);

# Para retificar que si se descontó el stock:
# select * from producto inner join categoria c on idCategoriaFK = c.idCategoria;

# Para retificar que si se creó el pedido:
# select * from cliente inner join pedido p on idCliente = idClienteFK;

# Mostrar el resultado del CALL al SP
select @pedido_id as id_pedido, @msg as mensaje;

# SP2: Cancelar el pedido
DELIMITER //
CREATE PROCEDURE spCancelarPedido ( # Recibir como parametro de entrada el id_pedido y el id_cliente
	IN p_idPedido INT, # cuál
    IN p_idCliente INT, # de quién
    OUT p_mensaje VARCHAR(100)
)
BEGIN
	DECLARE v_idCliente INT; # Para verificar que el pedido si pertenezca a ese cliente
    DECLARE v_estado VARCHAR(20); # Para ponerlo en 'cancelado'
	
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN 
		ROLLBACK;
        SET p_mensaje = 'Error: Toca revertirla';
	END;
    
    # Selecciona el cliente y el estado del pedido que se especificó
    SELECT idClienteFK, estadoPedido INTO v_idCliente, v_estado
    FROM pedido WHERE idPedido = p_idPedido;
    
    # Validar que el pedido exista y pertenezca al cliente indicado, si no debe mostrar mensaje de error
    IF v_idCliente IS NULL THEN
		SET p_mensaje = 'Pedido no encontrado';
    ELSEIF v_idCliente <> p_idCliente THEN
		SET p_mensaje = 'Este pedido no corresponde al cliente.';
	ELSEIF v_estado IN ('cancelado','entregado') THEN # validar que el pedido no este cancelado ni entregado. solo se va a poder cancelar pedidos que esten pendientes o enviado
		SET p_mensaje = CONCAT('Este pedido con el estado ',v_estado, ' ya no se puede cancelar.');
    ELSE 
		START TRANSACTION;
        
        UPDATE producto pr
        INNER JOIN detalle_pedido dp ON pr.idProducto = dp.idProductoFK # Tabla que muestra los productos que tienen un detalle
        SET pr.stockProducto = pr.stockProducto + dp.cantidad # Le sumas al stock la cantidad especificada en ese detalle
        WHERE dp.idPedidoFK = p_idPedido; # En el pedido especificado
        
        # Actualiza el estado
        UPDATE pedido SET estadoPedido = 'cancelado' WHERE idPedido = p_idPedido;
        
        COMMIT;
        # retornar como parametro de salida un mensaje de "Pedido #x: Cancelado, Stock restaurado para n productos" o algo por el estilo
        SET p_mensaje = CONCAT('Se ha cancelado el pedido #',p_idPedido);
	END IF;
END //
DELIMITER ;

CALL spCancelarPedido(7,3,@msg); # por si acaso este es el mismo que se creo en el SP1
select @msg; # si funciona :D

/*TAREA 1: Hacer ejemplo de procedimiento con cursor*/
# Cursor que recalcula el total de cada pedido
DELIMITER //
CREATE PROCEDURE recalcularTotales()
BEGIN
	DECLARE done INT DEFAULT FALSE; # Parece que esta bandera siempre se pone
    DECLARE p_idPedido INT;
    DECLARE p_cantidad INT;
    DECLARE p_precioUnit DECIMAL(10,2);
    DECLARE p_total DECIMAL(12,2) DEFAULT 0;
    DECLARE current_pedido INT DEFAULT NULL;
    
    DECLARE cursor_total CURSOR FOR 
		SELECT idPedidoFK, cantidad, precioUnit 
        FROM detalle_pedido
        ORDER BY idPedidoFK ASC;
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cursor_total;
    read_loop: LOOP
		FETCH cursor_total INTO p_idPedido, p_cantidad, p_precioUnit;
		IF done THEN
			IF current_pedido IS NOT NULL THEN # Para cuando llegué al final
				UPDATE pedido SET totalPedido = p_total WHERE idPedido = current_pedido;
			END IF;
			LEAVE read_loop;
		END IF;
        
        IF current_pedido IS NULL THEN # Para la primera
			SET current_pedido = p_idPedido;
		END IF;
        
        IF p_idPedido <> current_pedido THEN # Aka, se cambió de pedido
			UPDATE pedido p SET p.totalPedido = p_total WHERE current_pedido = p.idPedido;
            SET current_pedido = p_idPedido;
            SET p_total = 0;
		END IF;
		SET p_total = p_total + (p_cantidad * p_precioUnit);
	END LOOP;
    CLOSE cursor_total;
END //
DELIMITER ;

/*TAREA 2: Convertir los dos SPs anteriores (crearPedido y cancelarPedido) en vistas*/

