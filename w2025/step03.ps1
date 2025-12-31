Import-Module ActiveDirectory

$DominioDN = "DC=asir,DC=iescamp,DC=es"
$RutaCSV = ".\usuarios.csv"

# Parámetros
$usuario = "jugador"
$nombreCompleto = "Jugador"
$ou = (Get-ADDomain).UsersContainer
$password = ConvertTo-SecureString "qwe_123" -AsPlainText -Force

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

# Planiificar trabajo para el primer inicio de sesión de jugador. Lanzará el juego.
# VARIABLES
$Origen = ".\lanzar.ps1" 
$DestinoDir = "C:\Scripts"
$DestinoScript = "$DestinoDir\lanzar.ps1"
$TaskName = "LanzaPrimerInicio"
$Usuario = "jugador"

# Crear carpeta destino
if (-Not (Test-Path $DestinoDir)) {
    New-Item -Path $DestinoDir -ItemType Directory
}

# Copiar script
Copy-Item $Origen $DestinoScript -Force

# Acción: ejecutar PowerShell
$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -File `"$DestinoScript`""

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
            -UserPrincipalName "$($User.Usuario)@cerezo.asir" `
            -Department $User.Departamento `
            -Path $OUPath `
            -AccountPassword $Password `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "Usuario creado: $($User.Usuario)"
    }

    Add-ADGroupMember -Identity $User.Grupo -Members $User.Usuario -ErrorAction SilentlyContinue
}

Write-Host "Configuración finalizada. Máquina lista para ser clonada."
Write-Host "En el siguiente inicio de sesión del usuario 'jugador', se lanzará el juego."