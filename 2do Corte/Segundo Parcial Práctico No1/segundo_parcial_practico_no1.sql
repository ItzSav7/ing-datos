-- DROP DATABASE IF EXISTS tienda_tech;
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
 
 select * from clientes c left join pedidos p on c.cliente_id = p.cliente_id;
 
 /*Realice las siguientes operaciones en una misma sesión:
 (a) Inserte un nuevo cliente (nombre=Laura Rios, email=laura@mail.com, ciudad=Manizales).
 (b) Inserte un pedido para ese cliente del producto_id=3 con cantidad=2 y estado=pendiente.
 (c) Actualice el stock del producto_id=3 decrementandolo en 2.
 (d) Consulte con un JOIN el nombre del cliente, nombre del producto y estado del pedido recién creado.
Cláusulas requeridas: INSERT, UPDATE, SELECT con JOIN, WHERE
*/

DELIMITER //
CREATE PROCEDURE sp_nuevo_cliente(
	IN p_nombre varchar(100),
    IN p_email varchar(100),
    IN p_ciudad varchar(60),
    IN p_idProducto int,
    IN p_cantidad int,
    OUT p_mensaje varchar(200)
)
BEGIN
	DECLARE p_nuevoIdCliente int;

    -- Manejador de errores: si algo falla, hace ROLLBACK
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensaje = 'Error detectado: transacción revertida';
    END;
        START TRANSACTION;
 
        # Insertar a Laura a 'clientes'. Recibe los parámetros, aunque no se si debería hardcodearlo? no creo verdad? sería rarísimo
		insert into clientes (nombre, email, ciudad) VALUES (p_nombre, p_email, p_ciudad);
		
        SET p_nuevoIdCliente = last_insert_id();
        
		# Insertar el pedido
		insert into pedidos (cliente_id, producto_id, cantidad) # El default de estado ya es 'pendiente' así que no lo cambié yk
		values (p_nuevoIdCliente, p_idProducto, p_cantidad);
		
		# Actualizar Stock
		update productos
		set stock = stock - p_cantidad
		where producto_id = p_idProducto;
        COMMIT;
 
	# Consulte con un JOIN el nombre del cliente, nombre del producto y estado del pedido recién creado.
	SELECT c.nombre, p.nombre, pe.estado
    FROM clientes c
    INNER JOIN pedidos pe ON pe.cliente_id = p_nuevoIdCliente
    INNER JOIN productos p ON pe.producto_id = p.producto_id
    WHERE c.cliente_id = p_nuevoIdCliente;
    
	SET p_mensaje = CONCAT('Todo se creo bien.');
END //
DELIMITER ;

CALL sp_nuevo_cliente ("Laura Rios", "laura@mail.com", "Manizales", 3, 2, @msg);

# El select por separado
SELECT c.nombre, p.nombre, pe.estado
    FROM clientes c
    INNER JOIN pedidos pe ON pe.cliente_id = 9
    INNER JOIN productos p ON p.producto_id = 3
    WHERE c.cliente_id = 9;