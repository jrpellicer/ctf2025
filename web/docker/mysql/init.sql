SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS ctf2025
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

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
    tiempo INT UNSIGNED DEFAULT NULL,
    UNIQUE (codigo_hex, competicion_id),
    FOREIGN KEY (competicion_id) REFERENCES competiciones(id)
);


-- Crear tabla retos

CREATE TABLE retos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_hex CHAR(2) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    puntos INT DEFAULT 0,
    descripcion TEXT,
    UNIQUE (codigo_hex)
);


-- Insertar retos
INSERT INTO retos (codigo_hex, nombre, puntos) VALUES
    ('FA', 'Únete al Dominio', 900),
    ('17', 'No puedo trabajar', 300),
    ('DD', 'El nuevo de la oficina', 600),
    ('AD', 'Amplíame el disco que me quedo corto', 1800),
    ('11', '¿Por qué se ha apagado el equipo?', 300),
    ('5C', 'Un gran poder conlleva una gran responsabilidad', 400),
    ('23', 'Juegos de rol', 1900),
    ('AF', '¿Dónde está mi archivo?', 800),
    ('45', 'Un ruso está intentando hackearnos', 300),
    ('B3', 'No encuentro el Servidor WSUS', 1200);

-- Actualizar descripción del reto
UPDATE retos
SET descripcion = '
La máquina de Windows 11 está teniendo problemas para unirse al dominio de la empresa.
Investiga y resuelve el problema para que pueda unirse correctamente al dominio.

**Importante**: El nombre del equipo debe ser el siguiente correlativo al último equipo unido al dominio.

El administrador de sistemas ha proporcionado las siguientes credenciales para acceder a las máquinas:

**Windows Server 2025:**
    - *Usuario*: jugador
    - *Contraseña*: qwe_123

**Windows 11:**
    - *Usuario*: user
    - *Contraseña*: UserP@ss1!
'
WHERE codigo_hex = 'FA';

--

UPDATE retos
SET descripcion = '
Ha llamado al departamento de sistemas un directivo llamado Fernando Iglesias para informar que no puede trabajar. Según nos ha dicho, al intentar acceder a su máquina con Windows 11, recibe un mensaje de error que le impide iniciar sesión.

Fernando tiene que hacer la liquidación trimestral del IVA y necesita acceder urgentemente a su máquina para continuar con su trabajo. Si no lo consigue, dice que nos responsabilizaremos de las consecuencias. Que siempre la culpa es de los de sistemas...

Investiga el problema y encuentra una solución para que Fernando pueda acceder a su máquina y continuar con su trabajo.
'
WHERE codigo_hex = '17';

--

UPDATE retos
SET descripcion = '
Tenemos un nuevo empleado en la oficina. Se llama David Daroca y parece muy majo. 

Según nos informan del departamento de RRHH, David va a trabajar en el departamento de finanzas y necesita acceso a los recursos compartidos de la empresa.

Debemos crear una cuenta de usuario para David en el dominio de la empresa (siguiendo el estándar de nombres de usuario y localización en el Directorio Activo que sigue la empresa) y asignarlo a los grupos adecuados para que se pueda conectar a los recursos compartidos y se le apliquen las políticas de seguridad necesarias.'
WHERE codigo_hex = 'DD';

--

UPDATE retos
SET descripcion = '
El volumen de 196GB que tenemos en el servidor se prevee que sea insuficiente para las necesidades actuales. Afortunadamente hay un disco de 100GB conectado y sin utilizar que podemos utilizar para ampliar el volumen. 

Tu misión es ampliar el volumen existente hasta los 295GB utilizando el espacio disponible en el nuevo disco, asegurándote de que los datos actuales se mantengan intactos y que el sistema siga funcionando correctamente después de la ampliación.
'
WHERE codigo_hex = 'AD';

--

UPDATE retos
SET descripcion = '
Alguien ha apagado el servidor principal de la empresa sin motivo aparente, lo que ha provocado una interrupción en los servicios y la pérdida de datos importantes.

Tu misión es investigar las causas del apagado inesperado y revisar si el usuario ha dejado algún mensaje o información útil.
'
WHERE codigo_hex = '11';

--

UPDATE retos
SET descripcion = '
Un hacker está intentando acceder a nuestra red desde una IP rusa. Hemos detectado múltiples intentos de inicio de sesión fallidos en nuestros servidores provenientes de esta ubicación.

Sabemos que ha intentado suplantar la identidad de uno de nuestros empleados, David Navarro, para intentar acceder a nuestros sistemas. Y Sabemos que intenta conectarse al dominio pero no sabe el nombre del dominio, y el nombre con el que prueba es un tanto sospechoso.
'
WHERE codigo_hex = '45';