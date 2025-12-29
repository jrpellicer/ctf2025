-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS ctf2025;

-- Usar la base de datos creada
USE ctf2025;

-- Crear la tabla competiciones

CREATE TABLE competiciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME DEFAULT NULL,
    activa TINYINT(1) NOT NULL DEFAULT 0
);



-- Crear tabla equipos

CREATE TABLE equipos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_hex CHAR(6) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    competicion_id INT NOT NULL,
    puntos INT DEFAULT 0,
    UNIQUE (codigo_hex, competicion_id),
    FOREIGN KEY (competicion_id) REFERENCES competiciones(id)
);

-- Crear tabla retos

CREATE TABLE retos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_hex CHAR(2) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    puntos INT DEFAULT 0,
    UNIQUE (codigo_hex)
);

-- Insertar fases
INSERT INTO retos (codigo_hex, nombre, puntos) VALUES
    ('FA', 'Reto 1', 900),
    ('DD', 'Reto 2', 600),
    ('5C', 'Reto 3', 1500),
    ('23', 'Reto 4', 1900),
    ('AF', 'Reto 5', 300);
