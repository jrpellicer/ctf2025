Import-Module ActiveDirectory

# Parámetros
$usuario = "jugador"
$nombreCompleto = "Jugador"
$ou = (Get-ADDomain).UsersContainer
$password = ConvertTo-SecureString "jugador" -AsPlainText -Force

# Crear usuario si no existe
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

# Generar cadena hexadecimal aleatoria (6 caracteres)
$hex = -join ((0..5) | ForEach-Object { '{0:X}' -f (Get-Random -Maximum 16) })

# Ruta del escritorio del usuario (perfil por defecto)
$desktopPath = "C:\Users\Default\Desktop"

# Crear el escritorio si no existe (el perfil se crea al primer inicio de sesión,
# así que lo forzamos)
if (-not (Test-Path $desktopPath)) {
    New-Item -ItemType Directory -Path $desktopPath -Force | Out-Null
}

# Crear el fichero equipo.txt
$archivo = Join-Path $desktopPath "equipo.txt"
Set-Content -Path $archivo -Value $hex

