CREATE DATABASE gestion_litigios_judiciales;
USE gestion_litigios_judiciales;

USE gestion_litigios_judiciales;
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion TEXT
);

USE gestion_litigios_judiciales;
CREATE TABLE materia_legal (
    id_materia INT AUTO_INCREMENT PRIMARY KEY,
    nombre_materia VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

USE gestion_litigios_judiciales;
CREATE TABLE abogados (
    id_abogado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    matricula VARCHAR(30) NOT NULL UNIQUE,
    email VARCHAR(100),
    especialidad VARCHAR(50)
);

USE gestion_litigios_judiciales;
CREATE TABLE causas (
    id_causa INT AUTO_INCREMENT PRIMARY KEY,
    numero_expediente VARCHAR(50) NOT NULL UNIQUE,
    id_cliente INT NOT NULL,
    id_abogado INT NOT NULL,
    id_materia INT NOT NULL,
    estado VARCHAR(30),
    fecha_inicio DATE,
    fecha_cierre DATE,

    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_abogado) REFERENCES abogados(id_abogado),
    FOREIGN KEY (id_materia) REFERENCES materia_legal(id_materia)
);

USE gestion_litigios_judiciales;
CREATE TABLE etapas_proceso (
    id_etapa INT AUTO_INCREMENT PRIMARY KEY,
    nombre_etapa VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

USE gestion_litigios_judiciales;
CREATE TABLE audiencias (
    id_audiencia INT AUTO_INCREMENT PRIMARY KEY,
    id_causa INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    tipo VARCHAR(50),
    observaciones TEXT,
    FOREIGN KEY (id_causa) REFERENCES causas(id_causa)
);


