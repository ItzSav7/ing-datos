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
    idClienteFK INT NULL,
    fechaPedido DATETIME DEFAULT NOW(),
    estadoPedido ENUM('pendiente','enviado','entregado','cancelado') DEFAULT 'pendiente', # ENUM es como si fuera un dropdown menu
    totalPedido DECIMAL(12,2) DEFAULT 0,
    FOREIGN KEY (idClienteFK) REFERENCES cliente(idCliente)
    ON DELETE SET NULL
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

CREATE TABLE usuario (
	idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    nombreUsuario VARCHAR(100),
    contrasenaUsuario VARCHAR(30)
);

INSERT INTO usuario (nombreUsuario, contrasenaUsuario) VALUES ("Edwin Méndez","fundamentosdeelectrónicaanálog"), ("Edwin Cubides","maquinauniversal");

CREATE TABLE cambioProducto (
    idProduct INT PRIMARY KEY,
    nombreProducto VARCHAR(120) NOT NULL,
    precioProducto DECIMAL(10,2) NOT NULL,
    stockOld INT,
    stockProducto INT DEFAULT 0,
    idCategoriaFK INT,
    FOREIGN KEY (idCategoriaFK) REFERENCES categoria(idCategoria),
    idUsuarioFK INT,
    FOREIGN KEY (idUsuarioFK) REFERENCES usuario(idUsuario)
);
-- drop table cambioproducto;

CREATE TABLE clientesEliminados (
    idCliente INT PRIMARY KEY,
    nombreCliente VARCHAR(100) NOT NULL,
    emailCliente VARCHAR(150) UNIQUE NOT NULL,
    ciudadCliente VARCHAR(80),
    fechaRegistroCliente DATE DEFAULT NOW(),
    fechaEliminacion DATE DEFAULT NOW()
);
/* disparadores Triggers
tipos
before insert, before update, 
before delete: se ejecutan antes de la operación.

after insert, after update, 
after delete: se ejecutan despues de la operación.

sintaxis
DELIMITER //
CREATE TRIGGER nombreTrigger
AFTER INSERT ON nombreTabla
FOR EACH ROW
BEGIN
-- INSTRUCCIONES SQL

END //
DELIMITER;
*/

-- Trigger 1: Registrar el cambio de un update sobre producto y quién lo cambió
-- Antes
SELECT * FROM cambioProducto;

-- Trigger
DELIMITER //
CREATE TRIGGER t_cambioProducto
AFTER UPDATE ON producto
FOR EACH ROW
BEGIN
	INSERT INTO cambioProducto VALUES (new.idProducto, new.nombreProducto, new.precioProducto, old.stockProducto, new.stockProducto, new.idCategoriaFK, 1);
END //
DELIMITER ;

-- Llamarlo
UPDATE producto SET stockProducto = stockProducto + 1 WHERE idProducto = 2;

-- Después
SELECT * FROM cambioProducto INNER JOIN usuario ON idUsuarioFK = idUsuario;

-- Trigger 2: Cuando se elimine un cliente, registrarlo en una tabla de clientes eliminados
-- Antes
SELECT * FROM clientesEliminados;

-- Trigger
DELIMITER //
CREATE TRIGGER t_eliminoCliente
AFTER DELETE ON cliente
FOR EACH ROW
BEGIN
	INSERT INTO clientesEliminados VALUES (old.idCliente, old.nombreCliente, old.emailCliente, old.ciudadCliente, old.fechaRegistroCliente, NOW());
END //
DELIMITER ;

-- Llamarlo
DELETE FROM cliente WHERE idCliente = 3;

-- Después
SELECT * FROM clientesEliminados;