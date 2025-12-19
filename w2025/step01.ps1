 # ==================================================
# CONFIGURACIÓN
# ==================================================

# Datos de red
$IP = "192.168.1.10"
$Prefijo = 24
$Gateway = "192.168.1.1"
$DNS = @("127.0.0.1")

# Nombre del equipo
$NombreEquipo = "Galileo"

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
# CAMBIAR NOMBRE DEL EQUIPO
# ==================================================

if ($env:COMPUTERNAME -ne $NombreEquipo) {
    Write-Host "Cambiando nombre del equipo a $NombreEquipo..." -ForegroundColor Yellow
    Rename-Computer -NewName $NombreEquipo -Force -Restart
    exit
}
