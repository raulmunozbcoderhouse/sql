CREATE VIEW vw_causa_abierta_con_duracion AS
SELECT
    c.id_causa,
    c.numero_expediente,
    cl.nombre AS nombre_cliente,
    ab.nombre AS nombre_abogado,
    ml.nombre_materia,
    c.fecha_inicio,
    DATEDIFF(CURDATE(), c.fecha_inicio) AS dias_abierta
FROM causa c
JOIN cliente cl ON c.id_cliente = cl.id_cliente
JOIN abogado ab ON c.id_abogado = ab.id_abogado
JOIN materia_legal ml ON c.id_materia = ml.id_materia
WHERE c.fecha_cierre IS NULL;

CREATE VIEW vw_resumen_audiencia_por_causa AS
SELECT
    c.id_causa,
    c.numero_expediente,
    ml.nombre_materia,
    COUNT(a.id_audiencia) AS total_audiencia
FROM causa c
LEFT JOIN audiencia a ON c.id_causa = a.id_causa
JOIN materia_legal ml ON c.id_materia = ml.id_materia
GROUP BY c.id_causa, c.numero_expediente, ml.nombre_materia;


CREATE OR REPLACE VIEW vw_clientes_con_causas AS
SELECT
    cl.id_cliente,
    cl.nombre AS nombre_cliente,
    COUNT(c.id_causa) AS total_causa
FROM cliente cl
LEFT JOIN causa c ON cl.id_cliente = c.id_cliente
GROUP BY cl.id_cliente, cl.nombre;

CREATE VIEW vw_audiencias_mes_actual AS
SELECT
    a.id_audiencia,
    a.fecha_hora,
    a.tipo,
    c.numero_expediente,
    cl.nombre AS nombre_cliente
FROM audiencia a
JOIN causa c ON a.id_causa = c.id_causa
JOIN cliente cl ON c.id_cliente = cl.id_cliente
WHERE MONTH(a.fecha_hora) = MONTH(CURDATE())
  AND YEAR(a.fecha_hora) = YEAR(CURDATE());

DELIMITER //

CREATE PROCEDURE causas_activas_por_abogado(IN abogado_id INT)
BEGIN
    SELECT
        c.id_causa,
        c.numero_expediente,
        c.estado,
        c.fecha_inicio
    FROM causa c
    WHERE c.id_abogado = abogado_id
      AND c.fecha_cierre IS NULL;
END //

DELIMITER ;

CALL causas_activas_por_abogado(3);


DELIMITER //

CREATE PROCEDURE buscar_causa_por_cliente(IN nombre_cliente_busqueda VARCHAR(100))
BEGIN
    SELECT
        c.id_causa,
        c.numero_expediente,
        c.estado,
        c.fecha_inicio,
        c.fecha_cierre,
        ab.nombre AS nombre_abogado,
        ml.nombre_materia AS tipo_materia
    FROM causa c
    JOIN cliente cl ON c.id_cliente = cl.id_cliente
    JOIN abogado ab ON c.id_abogado = ab.id_abogado
    JOIN materia_legal ml ON c.id_materia = ml.id_materia
    WHERE cl.nombre LIKE CONCAT('%', nombre_cliente_busqueda, '%');
END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION causa_activa(fecha_cierre DATE)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    RETURN IF(fecha_cierre IS NULL, 'Activa', 'Cerrada');
END //

DELIMITER ;

SELECT
    id_causa,
    numero_expediente,
    causa_activa(fecha_cierre) AS estado_actual
FROM causa;


CREATE TABLE auditoria_causa (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_causa INT,
    accion VARCHAR(10),
    estado_anterior VARCHAR(30),
    estado_nuevo VARCHAR(30),
    fecha_anterior DATE,
    fecha_nueva DATE,
    usuario VARCHAR(100),
    fecha_evento DATETIME DEFAULT CURRENT_TIMESTAMP
);


DELIMITER //

CREATE TRIGGER trg_auditoria_update_causa
AFTER UPDATE ON causa
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_causa (
        id_causa,
        accion,
        estado_anterior,
        estado_nuevo,
        fecha_anterior,
        fecha_nueva,
        usuario
    )
    VALUES (
        OLD.id_causa,
        'UPDATE',
        OLD.estado,
        NEW.estado,
        OLD.fecha_cierre,
        NEW.fecha_cierre,
        USER() -- obtiene el usuario de la conexión
    );
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_auditoria_insert_causa
AFTER INSERT ON causa
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_causa (
        id_causa,
        accion,
        estado_nuevo,
        fecha_nueva,
        usuario
    )
    VALUES (
        NEW.id_causa,
        'INSERT',
        NEW.estado,
        NEW.fecha_cierre,
        USER()
    );
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_auditoria_delete_causa
AFTER DELETE ON causa
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_causa (
        id_causa,
        accion,
        estado_anterior,
        fecha_anterior,
        usuario
    )
    VALUES (
        OLD.id_causa,
        'DELETE',
        OLD.estado,
        OLD.fecha_cierre,
        USER()
    );
END //

DELIMITER ;


SELECT * FROM auditoria_causa ORDER BY fecha_evento DESC;



