-- ================================================================
-- CASO: Sistema de Gestion Hospitalaria
-- Tablas: medicos, pacientes, consultas
-- ================================================================
# DROP DATABASE IF EXISTS hospital_db;
CREATE DATABASE hospital_db CHARACTER SET utf8mb4;
USE hospital_db;

CREATE TABLE medicos (
    medico_id        INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    especialidad     VARCHAR(80)  NOT NULL,
    salario          DECIMAL(12,2) NOT NULL CHECK (salario > 0),
    fecha_ingreso    DATE NOT NULL,
    activo           TINYINT(1) DEFAULT 1
);

CREATE TABLE pacientes (
    paciente_id      INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    ciudad           VARCHAR(60),
    email            VARCHAR(100) UNIQUE,
    eps              VARCHAR(80)
);

CREATE TABLE consultas (
    consulta_id      INT AUTO_INCREMENT PRIMARY KEY,
    medico_id        INT NOT NULL,
    paciente_id      INT NOT NULL,
    fecha_consulta   DATE NOT NULL,
    diagnostico      VARCHAR(200),
    costo            DECIMAL(10,2) NOT NULL CHECK (costo > 0),
    estado           VARCHAR(20) DEFAULT "programada"
        CHECK (estado IN ("programada","realizada","cancelada")),
    FOREIGN KEY (medico_id)   REFERENCES medicos(medico_id),
    FOREIGN KEY (paciente_id) REFERENCES pacientes(paciente_id)
);

-- ================================================================
-- DML: DATOS DE PRUEBA
-- ================================================================
INSERT INTO medicos VALUES
 (1,"Dra. Laura Rios","Cardiologia",8500000.00,"2018-03-10",1),
 (2,"Dr. Carlos Mesa","Neurologia",9200000.00,"2016-07-22",1),
 (3,"Dra. Sofia Vega","Pediatria",7800000.00,"2020-01-15",1),
 (4,"Dr. Andres Gil","Ortopedia",8100000.00,"2019-06-01",1),
 (5,"Dra. Paula Mora","Cardiologia",8700000.00,"2017-09-30",1),
 (6,"Dr. Ivan Cruz","Dermatologia",7500000.00,"2021-04-12",0),
 (7,"Dra. Marta Leon","Neurologia",9500000.00,"2015-11-05",1),
 (8,"Dr. Felipe Ossa","Pediatria",7600000.00,"2022-02-28",1);

INSERT INTO pacientes VALUES
 (1,"Juan Perez","1985-04-12","Bogota","juan@mail.com","Sura"),
 (2,"Ana Gomez","1992-08-25","Medellin","ana@mail.com","Compensar"),
 (3,"Luis Vargas","1978-12-03","Cali","luis@mail.com","Sura"),
 (4,"Maria Diaz","2001-06-17","Bogota","maria@mail.com","Famisanar"),
 (5,"Carlos Ruiz","1965-01-30","Barranquilla","carlos@mail.com","Compensar"),
 (6,"Lucia Herrera","1990-09-08","Bogota","lucia@mail.com","Sura"),
 (7,"Pedro Soto","2005-03-22","Cali","pedro@mail.com","Famisanar"),
 (8,"Valeria Torres","1998-11-14","Medellin","valeria@mail.com","Compensar");

INSERT INTO consultas VALUES
 (1,1,1,"2024-01-10","Hipertension leve",150000,"realizada"),
 (2,1,3,"2024-01-22","Control cardiaco",150000,"realizada"),
 (3,2,2,"2024-02-05","Cefalea cronica",200000,"realizada"),
 (4,2,5,"2024-02-18","Migraña",200000,"cancelada"),
 (5,3,4,"2024-03-01","Control crecimiento",90000,"realizada"),
 (6,3,7,"2024-03-14","Fiebre alta",90000,"realizada"),
 (7,4,6,"2024-04-02","Fractura muñeca",250000,"realizada"),
 (8,4,1,"2024-04-15","Dolor rodilla",250000,"programada"),
 (9,5,8,"2024-05-03","Arritmia",180000,"realizada"),
 (10,5,2,"2024-05-20","Ecocardiograma",180000,"realizada"),
 (11,6,3,"2024-05-28","Dermatitis",120000,"cancelada"),
 (12,7,5,"2024-06-10","Epilepsia control",220000,"realizada"),
 (13,7,6,"2024-06-22","Resonancia",220000,"programada"),
 (14,8,4,"2024-07-01","Vacunacion",60000,"realizada"),
 (15,1,8,"2024-07-15","Hipertension severa",180000,"realizada"),
 (16,3,2,"2024-07-28","Seguimiento",90000,"programada");
 
 /*9. Cree la funcion fn_costo_total_paciente(p_paciente_id INT) que retorne la suma de costos de todas las consultas realizadas del paciente (solo estado=realizada).
 Luego escriba una consulta sobre la tabla pacientes que muestre nombre, ciudad, eps y costo_total (usando la funcion), 
 filtrando solo los pacientes cuyo costo_total supere el promedio de costo_total de todos los pacientes (use subconsulta con la misma funcion o calculo directo).
Clausulas requeridas: CREATE FUNCTION con SELECT SUM, SELECT usando funcion en columna y en WHERE con subconsulta
*/

-- Voy a asumir que toca comentar el script porque mejor que sobre a que falte
DELIMITER //
CREATE FUNCTION fn_costo_total_paciente(
	p_paciente_id INT -- Recibe el paciente a hacer los cálculos
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
	DECLARE v_suma_costos DECIMAL(12,2);
    
    -- Suma el costo de todas las consultas del paciente que se especificó
    SELECT sum(costo) INTO v_suma_costos 
    FROM consultas
    WHERE paciente_id = p_paciente_id AND estado = "realizada"; -- SOLO las realizadas
    
    RETURN v_suma_costos; -- y lo retorna :)
END //
DELIMITER ;

-- El SELECT usa la función de arriba
select 	nombre, 
		ciudad,
		eps,
        fn_costo_total_paciente(paciente_id) as costo_total
from pacientes
WHERE fn_costo_total_paciente(paciente_id) > (SELECT avg(fn_costo_total_paciente(paciente_id)) FROM pacientes); 
-- La subconsulta devuelve un único valor que es el promedio de TODOS los costos totales