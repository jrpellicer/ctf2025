Import-Module ActiveDirectory

# CONFIGURACIÓN
. "$PSScriptRoot\entorno.ps1"
$ou = (Get-ADDomain).UsersContainer
$RutaCSV = ".\usuarios.csv"

# Crear usuario jugador
if (-not (Get-ADUser -Filter "SamAccountName -eq '$usuario'" -ErrorAction SilentlyContinue)) {

    New-ADUser `
        -SamAccountName $usuario `
        -Name $nombreCompleto `
        -GivenName $nombreCompleto `
        -Enabled $true `
        -AccountPassword $password `
        -ChangePasswordAtLogon $false `
        -Path $ou

    # Añadir a administradores del dominio
    Add-ADGroupMember -Identity "Admins. del dominio" -Members $usuario
}
#----------------------------------------------------------------------------------
# Planificar trabajo para el primer inicio de sesión de jugador. Lanzará el juego.
# ----------------------------------------------------------------------------------
# Variables para la tarea programada
$Origen = ".\lanzar.ps1" 
$DestinoDir = "C:\Scripts"
$DestinoScript = "$DestinoDir\lanzar.ps1"
$TaskName = "LanzaPrimerInicio"

# Crear carpeta destino
if (-Not (Test-Path $DestinoDir)) {
    New-Item -Path $DestinoDir -ItemType Directory
}

# Copiar script forzando UTF-8 con BOM
$contenido = Get-Content $Origen -Raw
$utf8bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($DestinoScript, $contenido, $utf8bom)

# Acción: ejecutar PowerShell
$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$DestinoScript`""

# Trigger: al iniciar sesión del usuario jugador
$Trigger = New-ScheduledTaskTrigger -AtLogOn -User $Usuario

# Configuración de la tarea
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

# Registrar tarea CON MÁXIMOS PRIVILEGIOS
Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Settings $Settings `
    -User $Usuario `
    -RunLevel Highest `
    -Force

Write-Host "Tarea programada creada con máximos privilegios."

#----------------------------------------------------------------------------------
# Planificar trabajo para cada inicio de sesión de jugador. Lanzará el juego.
# ----------------------------------------------------------------------------------
# Variables para la tarea programada
$Origen = ".\demonio.ps1" 
$DestinoDir = "C:\Scripts"
$DestinoScript = "$DestinoDir\demonio.ps1"
$TaskName = "LanzaDemonio"

# Crear carpeta destino
if (-Not (Test-Path $DestinoDir)) {
    New-Item -Path $DestinoDir -ItemType Directory
}

# Copiar script forzando UTF-8 con BOM
$contenido = Get-Content $Origen -Raw
$utf8bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($DestinoScript, $contenido, $utf8bom)

# Acción: ejecutar PowerShell
$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$DestinoScript`""

# Trigger: al iniciar sesión del usuario jugador
$Trigger = New-ScheduledTaskTrigger -AtLogOn -User $Usuario

# Configuración de la tarea
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

# Registrar tarea CON MÁXIMOS PRIVILEGIOS
Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Settings $Settings `
    -User $Usuario `
    -RunLevel Highest `
    -Force

Write-Host "Tarea programada creada con máximos privilegios."

# ---------------------------------------------------------
# Crear estructura de OUs, usuarios, grupos y equipos en Active Directory
# ---------------------------------------------------------
# OUs a crear
$OUs = @(
    "Ventas",
    "IT",
    "RRHH",
    "Finanzas",
    "Direccion"
)

# Crear OUs
foreach ($OU in $OUs) {
    $OUPath = "OU=$OU,$DominioDN"
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OUPath'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $OU -Path $DominioDN
        Write-Host "OU creada: $OU"
    }
}

# Importar usuarios
$Usuarios = Import-Csv $RutaCSV

# Crear grupos únicos
$Grupos = $Usuarios | Select-Object -ExpandProperty Grupo -Unique

foreach ($Grupo in $Grupos) {
    if (-not (Get-ADGroup -Filter "Name -eq '$Grupo'" -ErrorAction SilentlyContinue)) {
        New-ADGroup `
            -Name $Grupo `
            -GroupScope Global `
            -GroupCategory Security `
            -Path "CN=Users,$DominioDN" `
            -ErrorAction SilentlyContinue
        Write-Host "Grupo creado: $Grupo"
    }
}

# Crear OU Grupos si no existe
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Grupos'" -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "Grupos" -Path $DominioDN
}

# Crear usuarios y añadirlos a grupos
foreach ($User in $Usuarios) {


    $OUPath = "$($User.OU),$DominioDN"

    $Password = ConvertTo-SecureString "qwe_123" -AsPlainText -Force

    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($User.Usuario)'" -ErrorAction SilentlyContinue)) {

        New-ADUser `
            -Name "$($User.Nombre) $($User.Apellido)" `
            -GivenName $User.Nombre `
            -Surname $User.Apellido `
            -SamAccountName $User.Usuario `
            -UserPrincipalName "$($User.Usuario)@$($Dominio)" `
            -Department $User.Departamento `
            -Path $OUPath `
            -AccountPassword $Password `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "Usuario creado: $($User.Usuario)"
    }

    Add-ADGroupMember -Identity $User.Grupo -Members $User.Usuario -ErrorAction SilentlyContinue
}

# Crear equipos
1..24 | ForEach-Object {
    New-ADComputer `
      -Name "PC-$($_.ToString('00'))" `
      -SamAccountName "PC-$($_.ToString('00'))$" `
      -Path "CN=Computers,$DominioDN" `
      -Enabled $true

      Write-Host "Equipo añadido al dominio: PC-$($_.ToString('00'))"
}

# ---------------------------------------------------------
# Crear Discos y Volúmenes
# ---------------------------------------------------------

# Crear ruta de almacenamiento de los discos virtuales si no existe
$discosPath = "C:\DiscosVirtuales"
if (-not (Test-Path $discosPath)) {
    New-Item -ItemType Directory -Path $discosPath
}

# Definir las rutas de los discos virtuales y el archivo de comandos temporal
$vhd1Path = "C:\DiscosVirtuales\Disco1.vhdx"
$vhd2Path = "C:\DiscosVirtuales\Disco2.vhdx"
$vhd3Path = "C:\DiscosVirtuales\Disco3.vhdx"
$vhd4Path = "C:\DiscosVirtuales\Disco4.vhdx"

$scriptFile = "$env:TEMP\diskpart_script.txt"

# Crear la lista de comandos para Diskpart

$commands = @(
    "create vdisk file=`"$vhd1Path`" maximum=102400 type=expandable",
    "select vdisk file=`"$vhd1Path`"",
    "attach vdisk",
    "create vdisk file=`"$vhd2Path`" maximum=102400 type=expandable",
    "select vdisk file=`"$vhd2Path`"",
    "attach vdisk",
    "exit"
)

# Guardar los comandos en el archivo de texto
$commands | Out-File -FilePath $scriptFile -Encoding ASCII -Force

# Ejecutar Diskpart con el script creado
Start-Process diskpart.exe -ArgumentList "/s $scriptFile" -Wait -NoNewWindow

# Crear el pool de almacenamiento y el disco virtual
$disks = Get-PhysicalDisk | Where-Object CanPool -eq $true

New-StoragePool `
    -FriendlyName "PoolDisks" `
    -StorageSubsystemFriendlyName "Windows Storage*" `
    -PhysicalDisks $disks

New-VirtualDisk `
    -StoragePoolFriendlyName "PoolDisks" `
    -FriendlyName "VolAdmin" `
    -ResiliencySettingName Simple `
    -Size 197GB `
    -ProvisioningType Thin

$vdisk = Get-VirtualDisk -FriendlyName "VolAdmin"
$disk  = Get-Disk | Where-Object FriendlyName -eq $vdisk.FriendlyName

# Inicializar el disco y crear la partición
Initialize-Disk $disk.Number -PartitionStyle GPT

New-Partition `
    -DiskNumber $disk.Number `
    -UseMaximumSize `
    -DriveLetter R

# Formatar el volumen
Format-Volume `
    -DriveLetter R `
    -FileSystem NTFS `
    -NewFileSystemLabel "ADMIN_DATA" `
    -Confirm:$false


# Crear la lista de comandos para Diskpart para discos 3 y 4
$commands = @(
    "create vdisk file=`"$vhd3Path`" maximum=102400 type=expandable",
    "select vdisk file=`"$vhd3Path`"",
    "attach vdisk",
    "create vdisk file=`"$vhd4Path`" maximum=51200 type=expandable",
    "select vdisk file=`"$vhd4Path`"",
    "attach vdisk",
    "create partition primary",
    "format fs=ntfs quick label=`"Backups`"",
    "assign letter=E",
    "exit"
)

# Guardar los comandos en el archivo de texto
$commands | Out-File -FilePath $scriptFile -Encoding ASCII -Force

# Ejecutar Diskpart con el script creado
Start-Process diskpart.exe -ArgumentList "/s $scriptFile" -Wait -NoNewWindow

# Limpiar el archivo temporal
Remove-Item $scriptFile

# Preparación para tarea programa al inicio de la sesión de 'jugador' para exponer los discos virtuales

$scriptFile = "C:\DiscosVirtuales\diskpart_script.txt"

# Crear la lista de comandos para Diskpart para todos los discos virtuales
$commands = @(
    "select vdisk file=`"$vhd3Path`"",
    "attach vdisk",
    "select vdisk file=`"$vhd4Path`"",
    "attach vdisk",
    "select vdisk file=`"$vhd1Path`"",
    "attach vdisk",
    "select vdisk file=`"$vhd2Path`"",
    "attach vdisk",
    "exit"
)

# Guardar los comandos en el archivo de texto
$commands | Out-File -FilePath $scriptFile -Encoding ASCII -Force

# -------------------------------------------------------------------------------
# Configuración tarea planificada para exponer discos al iniciar sesión 'jugador'
# -------------------------------------------------------------------------------
$TaskName = "DiskPart_AlIniciarSesion"
$DiskPartExe = "C:\Windows\System32\diskpart.exe"

# Acción: ejecutar DiskPart de forma oculta
$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -WindowStyle Hidden -Command `"& '$DiskPartExe' /s '$scriptFile'`""

# Disparador: inicio de sesión del usuario
$Trigger = New-ScheduledTaskTrigger `
    -AtLogOn `
    -User $usuario

# Principal: ejecutar con máximos privilegios
$Principal = New-ScheduledTaskPrincipal `
    -UserId $usuario `
    -LogonType Interactive `
    -RunLevel Highest

# Configuración adicional
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -Hidden

# Registrar la tarea
Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Principal $Principal `
    -Settings $Settings `
    -Force


Write-Host "Tarea programada '$TaskName' creada correctamente."

# ===============================
# Configuración de copias de seguridad
# ===============================
$BasePath   = "C:\DatosEmpresa"
$Fecha      = Get-Date -Format "yyyyMMdd_HHmmss"

# LISTAS DE NOMBRES DE DIRECTORIOS Y EXTENSIONES
$Departamentos = @(
    "Finanzas",
    "RecursosHumanos",
    "Informatica",
    "Ventas",
    "Marketing",
    "Logistica",
    "Proyectos"
)

$Subcarpetas = @(
    "Documentos",
    "Informes",
    "Contratos",
    "Presupuestos",
    "Planificacion",
    "Historico"
)

$Extensiones = @(".txt", ".pdf", ".dat", ".docx")

# CREAR ESTRUCTURA DE DIRECTORIOS
Write-Host "Creando estructura de directorios..." -ForegroundColor Cyan

foreach ($Dept in $Departamentos) {
    foreach ($Sub in $Subcarpetas) {
        $Ruta = Join-Path $BasePath "$Dept\$Sub"
        New-Item -ItemType Directory -Path $Ruta -Force | Out-Null

        # CREAR ARCHIVOS ALEATORIOS
        $NumArchivos = Get-Random -Minimum 15 -Maximum 25

        for ($i = 1; $i -le $NumArchivos; $i++) {

            $NombreArchivo = "{0}_{1}{2}" -f `
                ($Sub.Substring(0,3)), `
                (Get-Random -Minimum 1000 -Maximum 9000), `
                ($Extensiones | Get-Random)

            $RutaArchivo = Join-Path $Ruta $NombreArchivo

            # Tamaño entre 500 bytes y 2 MB
            $Tamano = Get-Random -Minimum 500 -Maximum 2097152

            # Generar contenido aleatorio
            $Bytes = New-Object byte[] $Tamano
            (New-Object System.Random).NextBytes($Bytes)

            [System.IO.File]::WriteAllBytes($RutaArchivo, $Bytes)
        }
    }
}

# CREAR ARCHIVOS A RESTAURAR
$Ruta = Join-Path $BasePath "Ventas\Contratos"
$NombreArchivo = "Con_9831.docx"
$RutaArchivo = Join-Path $Ruta $NombreArchivo
$Tamano = 1234

# Generar contenido aleatorio
$Bytes = New-Object byte[] $Tamano
(New-Object System.Random).NextBytes($Bytes)

[System.IO.File]::WriteAllBytes($RutaArchivo, $Bytes)


# COPIA DE SEGURIDAD CON WINDOWS SERVER BACKUP

Write-Host "Instalando Windows Server Backup..." -ForegroundColor Green
Install-WindowsFeature -Name Windows-Server-Backup

Write-Host "Iniciando copia de seguridad con Windows Server Backup..." -ForegroundColor Cyan

$OrigenBackup = "C:\DatosEmpresa"
$DestinoBackup = "E:"

wbadmin start backup `
    -backupTarget:$DestinoBackup `
    -include:$OrigenBackup `
    -quiet

Write-Host "Copia de seguridad finalizada correctamente." -ForegroundColor Green

# ELIMINACIÓN ARCHIVO A RESTAURAR
Remove-Item $RutaArchivo

Write-Host "Archivo $RutaArchivo eliminado." -ForegroundColor Cyan


Write-Host "Configuración finalizada. Máquina lista para ser clonada."
Write-Host "En el siguiente inicio de sesión del usuario $($User.Usuario), se lanzará el juego."

