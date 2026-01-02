Import-Module ActiveDirectory

# Configurar notificaciones emergentes en Centro de Notificaciones
Add-Type -AssemblyName System.Windows.Forms
$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Icon = [System.Drawing.SystemIcons]::Information

# Mostrar notificaciones emergentes
function Mostrar-Notificacion {
    param (
        [string]$Titulo,
        [string]$Texto
    )

    $notify.BalloonTipTitle = $Titulo
    $notify.BalloonTipText  = $Texto
    $notify.Visible = $true
    $notify.ShowBalloonTip(5000)
}

# Resolver reto
function Resolver-Reto {
    param (
        [string]$equipo,
        [string]$NumeroReto,
        [string]$Identificador
    )

    $codigo = "{0:X8}" -f ((($v=[Convert]::ToUInt32("$equipo$Identificador",16)) -shl 11 -bor ($v -shr 21)) -band 0xFFFFFFFF)

    Mostrar-Notificacion "Reto Resuelto" "Código del reto ${NumeroReto}: $codigo"
    Add-Content -Path $archivoReto -Value "Código del reto ${NumeroReto}: $codigo"
}

# Obtener código de equipo
$desktopPath = "$env:USERPROFILE\Desktop"
$archivoEquipo = Join-Path $desktopPath "equipo.txt"
$equipo = Get-Content -Path $archivoEquipo
$archivoReto = Join-Path $desktopPath "retos.txt"

$reto1Resuelto = $false
$reto2Resuelto = $false
$reto3Resuelto = $false
while ($true) {
# ---------------------------------------------------------
# Reto 1. Unir el equipo al dominio
# ---------------------------------------------------------

    if (-not $reto1Resuelto) {
        $pc = Get-ADComputer -Filter "Name -eq 'PC-25'"

        if ($pc) {
            Resolver-Reto -equipo $equipo -NumeroReto 1 -Identificador "FA"
            $reto1Resuelto = $true
        }
    }

# ---------------------------------------------------------
# Reto 2. Activar usuario figlesias
# ---------------------------------------------------------

    if (-not $reto2Resuelto) {
        if ((Get-ADUser -Identity figlesias).Enabled -eq $true) {
            Resolver-Reto -equipo $equipo -NumeroReto 2 -Identificador "17"
            $reto2Resuelto = $true
        }
    }

# ---------------------------------------------------------
# Reto 3. Comprobar usuario en OU y grupo
# ---------------------------------------------------------

    if (-not $reto3Resuelto) {
        $usuario = "ddaroca"
        $ou = "OU=Finanzas,DC=asir,DC=iescamp,DC=es"
        $grupo = "GRP_Finanzas"

        # Obtener el usuario dentro de la OU
        $usr = Get-ADUser -Filter "SamAccountName -eq '$usuario'" -SearchBase $ou -ErrorAction SilentlyContinue

        # IF para comprobar existencia y pertenencia al grupo
        if ($usr -and (Get-ADUser $usr -Properties MemberOf).MemberOf -contains (Get-ADGroup $grupo).DistinguishedName) {
            Resolver-Reto -equipo $equipo -NumeroReto 3 -Identificador "DD"
        }
        $reto3Resuelto = $true
    }


# ---------------------------------------------------------
    Start-Sleep -Seconds 10
}
