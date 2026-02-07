# ==================================================
# CONFIGURACIÓN
# ==================================================

. "$PSScriptRoot\entorno.ps1"

# ==================================================
# DETECTAR ADAPTADOR ACTIVO
# ==================================================

$Adaptador = Get-NetAdapter |
    Where-Object {
        $_.Status -eq "Up" -and
        $_.HardwareInterface -eq $true
    } |
    Select-Object -First 1

if (-not $Adaptador) {
    Write-Error "No se ha encontrado ningún adaptador de red activo."
    exit 1
}

$InterfaceAlias = $Adaptador.Name
Write-Host "Adaptador detectado: $InterfaceAlias" -ForegroundColor Cyan

# ==================================================
# CONFIGURAR RED
# ==================================================

Write-Host "Configurando red..." -ForegroundColor Yellow

Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Remove-NetIPAddress -Confirm:$false

Get-NetRoute -InterfaceAlias $InterfaceAlias -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue |
    Remove-NetRoute -Confirm:$false

New-NetIPAddress `
    -InterfaceAlias $InterfaceAlias `
    -IPAddress $IP `
    -PrefixLength $Prefijo `
    -DefaultGateway $Gateway

Set-DnsClientServerAddress `
    -InterfaceAlias $InterfaceAlias `
    -ServerAddresses $DNS

# ==================================================
# CREAR USUARIO LOCAL
# ==================================================
# Comprobar si el usuario ya existe
if (Get-LocalUser -Name $usuario -ErrorAction SilentlyContinue) {
    Write-Host "El usuario '$usuario' ya existe." -ForegroundColor Yellow
} else {
    # Crear usuario local
    New-LocalUser `
        -Name $usuario `
        -FullName $nombreCompleto `
        -Password $password `
        -PasswordNeverExpires `
        -AccountNeverExpires `
        -Description "Usuario local con privilegios de administrador"

    Write-Host "Usuario '$usuario' creado correctamente." -ForegroundColor Green
}

# Añadir al grupo Administradores
if (-not (Get-LocalGroupMember -Group "Administradores" -Member $usuario -ErrorAction SilentlyContinue)) {
    Add-LocalGroupMember -Group "Administradores" -Member $usuario
    Write-Host "Usuario '$usuario' añadido al grupo Administradores." -ForegroundColor Green
} else {
    Write-Host "El usuario '$usuario' ya pertenece al grupo Administradores." -ForegroundColor Yellow
}
