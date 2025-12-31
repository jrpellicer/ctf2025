# ctf2025
Capture the Flag Windows Server 2025

## Instalación Servidor Web

Instalamos en una máquina Linux con IP Pública y docker instalado el servidor web para llevar la lógica de la competición.

```
cd web
docker-compose up -d
```

## Scripts preparación Windows Server 2025

### Creación imagen base de Windows Server 2025

#### Instalación de Windows Server 2025 

Hacer una instalación limpia de Windows Server 2025. La contraseña del usuario adminnistrador no debe hacerse pública y sirve cualquiera.

Una vez instalado, sin modificar ningún parámetro de configuración, clonar este repositorio.

### Lanzamiento de script de configuración

Lanzar el script `step01.ps1` para la configuración del nombre del equipo y adaptador de red.

### Lanzamiento de script de creación del dominio

Una vez reiniciado automáticamente el servidor, lanzar el script `step02.ps1` para la creación del dominio.

### Lanzamiento de script de creación de usuarios

Lanzar el script `step03.ps1` para la creación de usuarios.

### Clonación de la máquina

En este punto ya se puede clonar la máquina (o crear plantillas) para que cada equipo disponga de la misma imagen base.

## Personalización de los flags y creación de los retos



## Scripts preparación Windows 11
