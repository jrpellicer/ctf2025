# ctf2025
Capture the Flag Windows Server 2025

## Instalación Servidor Web

Instalamos en una máquina Linux con IP Pública y docker instalado el servidor web para llevar la lógica de la competición.

```
cd web
```

```
docker-compose up -d
```

## Scripts preparación Windows Server 2025

### Creación imagen base de Windows Server 2025

#### Instalación de Windows Server 2025 

En el hipervisor, configurar el adaptador de red de la máquina virtual para que tenga conexión a Internet (*NAT* en VBox, *Default* en IsardVDI).

Hacer una instalación limpia de Windows Server 2025. La contraseña del usuario administrador no debe hacerse pública y sirve cualquiera.

Una vez instalado, sin modificar ningún parámetro de configuración, descargar este repositorio. Abrimos consola de Powershell con privilegios de **administrador**.

```
Invoke-WebRequest `
  -Uri "https://github.com/jrpellicer/ctf2025/archive/refs/heads/main.zip" `
  -OutFile "repo.zip"
```

```
Expand-Archive repo.zip -DestinationPath C:\ctf
```

Apagar la máquina y configurar el adaptador de red en el hipervisor para que esté en modo Red Interna (*Personal* en IsardVDI).

### Lanzamiento de script de configuración

Lanzar el script `step01.ps1` para la configuración del nombre del equipo y adaptador de red.

```
cd C:\ctf\ctf2025-main\w2025\
```

```
.\step01.ps1
```

### Lanzamiento de script de creación del dominio

Una vez reiniciado automáticamente el servidor, lanzar el script `step02.ps1` para la creación del dominio.

```
cd C:\ctf\ctf2025-main\w2025\
```

```
.\step02.ps1
```

### Lanzamiento de script de creación de usuarios

Lanzar el script `step03.ps1` para la creación de usuarios.

```
cd C:\ctf\ctf2025-main\w2025\
```

```
.\step03.ps1
```

### Clonación de la máquina

En este punto ya se puede clonar la máquina (o crear plantillas) para que cada equipo disponga de la misma imagen base.

## Personalización de los flags y creación de los retos

Al iniciar sesión por primera vez con el usuario definido en `entorno.ps1` (`adminsistema` por defecto) se lanza automáticamente el script de personalización de equipos y flags.

## Scripts preparación Windows 11
En el hipervisor, configurar el adaptador de red de la máquina virtual para que tenga conexión a Internet (*NAT* en VBox, *Default* en IsardVDI).

Hacer una instalación limpia de Windows 11. La contraseña del usuario administrador no debe hacerse pública y sirve cualquiera.

Una vez instalado, sin modificar ningún parámetro de configuración, descargar este repositorio. Abrimos consola de Powershell con privilegios de **administrador**.

```
Invoke-WebRequest `
  -Uri "https://github.com/jrpellicer/ctf2025/archive/refs/heads/main.zip" `
  -OutFile "repo.zip"
```

```
Expand-Archive repo.zip -DestinationPath C:\ctf
```

Apagar la máquina y configurar el adaptador de red en el hipervisor para que esté en modo Red Interna (*Personal* en IsardVDI).

### Lanzamiento de script de configuración

Lanzar el script `step01.ps1` para la configuración del nombre del equipo y adaptador de red.

```
cd C:\ctf\ctf2025-main\w11\
```

```
.\step01.ps1
```
