CREATE DATABASE gestion_litigio_judicial;
USE gestion_litigio_judicial;

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

CREATE TABLE etapas_proceso (
    id_etapa INT AUTO_INCREMENT PRIMARY KEY,
    nombre_etapa VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE audiencia (
    id_audiencia INT AUTO_INCREMENT PRIMARY KEY,
    id_causa INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    tipo VARCHAR(50),
    observaciones TEXT,
    FOREIGN KEY (id_causa) REFERENCES causa(id_causa)
);