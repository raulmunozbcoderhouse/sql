CREATE DATABASE gestion_litigio_judicial_final;
USE gestion_litigio_judicial_final;

CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion TEXT
);

CREATE TABLE materia_legal (
    id_materia INT AUTO_INCREMENT PRIMARY KEY,
    nombre_materia VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE abogado (
    id_abogado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    matricula VARCHAR(30) NOT NULL UNIQUE,
    email VARCHAR(100),
    especialidad VARCHAR(50)
);

CREATE TABLE causa (
    id_causa INT AUTO_INCREMENT PRIMARY KEY,
    numero_expediente VARCHAR(50) NOT NULL UNIQUE,
    id_cliente INT NOT NULL,
    id_abogado INT NOT NULL,
    id_materia INT NOT NULL,
    estado VARCHAR(30),
    fecha_inicio DATE,
    fecha_cierre DATE,

    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_abogado) REFERENCES abogado(id_abogado),
    FOREIGN KEY (id_materia) REFERENCES materia_legal(id_materia)
);

CREATE TABLE audiencia (
    id_audiencia INT AUTO_INCREMENT PRIMARY KEY,
    id_causa INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    tipo VARCHAR(50),
    observaciones TEXT,
    FOREIGN KEY (id_causa) REFERENCES causa(id_causa)
);

USE gestion_litigio_judicial_final;

CREATE VIEW vista_causas_detalle AS
SELECT 
    c.id_causa,
    c.numero_expediente,
    c.estado,
    c.fecha_inicio,
    c.fecha_cierre,

    cl.id_cliente,
    cl.nombre AS nombre_cliente,
    cl.dni AS dni_cliente,
    cl.telefono AS telefono_cliente,
    cl.email AS email_cliente,

    ab.id_abogado,
    ab.nombre AS nombre_abogado,
    ab.matricula AS matricula_abogado,
    ab.email AS email_abogado,
    ab.especialidad AS especialidad_abogado,

    ml.id_materia,
    ml.nombre_materia,
    ml.descripcion AS descripcion_materia

FROM causa c
JOIN cliente cl ON c.id_cliente = cl.id_cliente
JOIN abogado ab ON c.id_abogado = ab.id_abogado
JOIN materia_legal ml ON c.id_materia = ml.id_materia;

SELECT * FROM gestion_litigio_judicial_final.vista_causas_detalle;

CREATE VIEW vista_audiencias_proximas AS
SELECT 
    a.id_audiencia,
    a.fecha_hora,
    a.tipo AS tipo_audiencia,
    c.numero_expediente,
    cl.nombre AS nombre_cliente
FROM audiencia a
JOIN causa c ON a.id_causa = c.id_causa
JOIN cliente cl ON c.id_cliente = cl.id_cliente
WHERE a.fecha_hora >= NOW()
ORDER BY a.fecha_hora ASC;

SELECT * FROM gestion_litigio_judicial_final.vista_audiencias_proximas;

CREATE VIEW vista_clientes_con_causas AS
SELECT 
    cl.id_cliente,
    cl.nombre AS nombre_cliente,
    cl.dni,
    c.numero_expediente,
    c.estado
FROM cliente cl
JOIN causa c ON cl.id_cliente = c.id_cliente
-- Si quieres solo causas abiertas:
-- WHERE c.estado = 'Abierta'
ORDER BY cl.nombre;

SELECT * FROM gestion_litigio_judicial_final.vista_clientes_con_causas;

SELECT * FROM gestion_litigio_judicial_final.vista_abogados_actuaciones;

CREATE VIEW vista_historial_causa AS
SELECT 
    c.id_causa,
    c.numero_expediente,
    c.estado,
    c.fecha_inicio,
    c.fecha_cierre,
    cl.nombre AS nombre_cliente,
    ab.nombre AS nombre_abogado,
    ml.nombre_materia,
    au.id_audiencia,
    au.fecha_hora,
    au.tipo AS tipo_audiencia,
    au.observaciones
FROM causa c
JOIN cliente cl ON c.id_cliente = cl.id_cliente
JOIN abogado ab ON c.id_abogado = ab.id_abogado
JOIN materia_legal ml ON c.id_materia = ml.id_materia
LEFT JOIN audiencia au ON c.id_causa = au.id_causa
ORDER BY c.id_causa, au.fecha_hora ASC;

SELECT * FROM gestion_litigio_judicial_final.vista_historial_causa;

USE gestion_litigio_judicial_final;

DELIMITER //
CREATE FUNCTION calcular_dias_causa(p_id_causa INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE dias INT;
    SELECT DATEDIFF(CURDATE(), fecha_inicio)
    INTO dias
    FROM causa
    WHERE id_causa = p_id_causa;
    RETURN dias;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION obtener_cliente_por_causa(p_id_causa INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE cliente_nombre VARCHAR(100);
    SELECT cl.nombre
    INTO cliente_nombre
    FROM causa c
    JOIN cliente cl ON c.id_cliente = cl.id_cliente
    WHERE c.id_causa = p_id_causa;
    RETURN cliente_nombre;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE registrar_audiencia(
    IN p_id_causa INT,
    IN p_fecha_hora DATETIME,
    IN p_tipo VARCHAR(50),
    IN p_observaciones TEXT
)
BEGIN
    IF p_fecha_hora < NOW() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No se puede registrar una audiencia en el pasado';
    ELSE
        INSERT INTO audiencia (id_causa, fecha_hora, tipo, observaciones)
        VALUES (p_id_causa, p_fecha_hora, p_tipo, p_observaciones);
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE cerrar_causa(IN p_id_causa INT)
BEGIN
    UPDATE causa
    SET estado = 'Cerrada',
        fecha_cierre = CURDATE()
    WHERE id_causa = p_id_causa
      AND estado <> 'Cerrada';
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_insert_audiencia
BEFORE INSERT ON audiencia
FOR EACH ROW
BEGIN
    IF NEW.fecha_hora < NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede insertar una audiencia en el pasado';
    END IF;
END //
DELIMITER ;

CREATE TABLE bitacora_causa (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_causa INT NOT NULL,
    fecha_cierre DATETIME,
    usuario VARCHAR(100),
    FOREIGN KEY (id_causa) REFERENCES causa(id_causa)
);
SELECT * FROM gestion_litigio_judicial_final.bitacora_causa;

DELIMITER //
CREATE TRIGGER after_update_causa
AFTER UPDATE ON causa
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Cerrada' AND OLD.estado <> 'Cerrada' THEN
        INSERT INTO bitacora_causa (id_causa, fecha_cierre, usuario)
        VALUES (NEW.id_causa, NOW(), USER());
    END IF;
END //
DELIMITER ;
