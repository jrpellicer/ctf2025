Import-Module ActiveDirectory

# --- Inicialización WinRT ---
$null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
$null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime]

function Mostrar-Notificacion {
    param (
        [string]$Titulo,
        [string]$Texto
    )

    $AppId = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"

    $template = @"
<?xml version="1.0" encoding="UTF-8"?>
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text><![CDATA[$Titulo]]></text>
            <text><![CDATA[$Texto]]></text>
        </binding>
    </visual>
</toast>
"@

    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($template)

    $toast = New-Object Windows.UI.Notifications.ToastNotification($xml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId).Show($toast)
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

# -------------------------------------------------------
# Obtener código de equipo
# -------------------------------------------------------
# Esperamos 15 segundos para dar tiempo que se genere el equipo
Start-Sleep -Seconds 15

$desktopPath = "$env:USERPROFILE\Desktop"
#$archivoEquipo = Join-Path $desktopPath "equipo.txt"
$archivoEquipo = "C:\equipo.txt"
$equipo = Get-Content -Path $archivoEquipo
$archivoReto = Join-Path $desktopPath "retos.txt"

$reto1Resuelto = $false
$reto2Resuelto = $false
$reto3Resuelto = $false
$reto4Resuelto = $false
$reto6Resuelto = $false
$reto7Resuelto = $false
$reto8Resuelto = $false
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
# Reto 4. Comprobar volumen de datos ADMIN_DATA mayor de 290GB
# ---------------------------------------------------------

    if (-not $reto4Resuelto) {

        # Obtener tamaño del volumen ADMIN_DATA
        $volumen = Get-Volume -FileSystemLabel "ADMIN_DATA" -ErrorAction SilentlyContinue
        if ($volumen -and $volumen.SizeRemaining -gt 290GB) {
            Resolver-Reto -equipo $equipo -NumeroReto 4 -Identificador "AD"
            $reto4Resuelto = $true
        }
    }

# ---------------------------------------------------------
# Reto 6. Comprobar que el usuario Miguel Torres pertenece al grupo administradores del dominio
# ---------------------------------------------------------

    if (-not $reto6Resuelto) {

        # Obtener el usuario Miguel Torres
        $usuario = Get-ADUser -Identity "mtorres" -ErrorAction SilentlyContinue

        # Obtener el ID del grupo de administradores del dominio
        $domainSID = (Get-ADDomain).DomainSID.Value
        $grupoAdmin = Get-ADGroup -Identity "$domainSID-512"

        # Comprobar si pertenece al grupo de administradores del dominio
        if ($usuario -and ($usuario.MemberOf -contains $grupoAdmin.DistinguishedName)) {
            Resolver-Reto -equipo $equipo -NumeroReto 6 -Identificador "5C"
            $reto6Resuelto = $true
        }
    }

# ---------------------------------------------------------
# Reto 7. Comprobar que rol de Espacio de Nombres DFS está instalado
# ---------------------------------------------------------

    if (-not $reto7Resuelto) {

        # Obtener si esta instalado el rol de Espacio de Nombres DFS
        $dfsInstalado = (Get-WindowsFeature FS-DFS-Namespace).Installed

        # Comprobar si esta instalado el rol de Espacio de Nombres DFS
        if ($dfsInstalado -eq $true) {
            Resolver-Reto -equipo $equipo -NumeroReto 7 -Identificador "23"
            $reto7Resuelto = $true
        }
    }


# ---------------------------------------------------------
# Reto 8. Comprobar archivo restaurado
# ---------------------------------------------------------

    if (-not $reto8Resuelto) {
        $archivo = "contrato_9831.txt"
        $ruta = "C:\Archivos\Contratos"
        $tamano=1234 # Tamaño en bytes esperado
        $archivoRestaurado = Join-Path $ruta $archivo

        $item = Get-Item $archivoRestaurado -ErrorAction SilentlyContinue

        if ($item -and $item.Length -eq $tamano) {
            Resolver-Reto -equipo $equipo -NumeroReto 8 -Identificador "AF"
            $reto8Resuelto = $true
        }
    }

# ---------------------------------------------------------
    Start-Sleep -Seconds 5
}
