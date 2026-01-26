Import-Module ActiveDirectory

# ---------------------------------------------------------
# Generamos código del equipo y lo dejamos en el escritorio
# ---------------------------------------------------------

# Generar cadena hexadecimal aleatoria (6 caracteres)
$equipo = -join ((0..5) | ForEach-Object { '{0:X}' -f (Get-Random -Maximum 16) })

# Ruta del escritorio del usuario
$desktopPath = "$env:USERPROFILE\Desktop"

# Crear el fichero equipo.txt
$archivo = Join-Path $desktopPath "equipo.txt"
Set-Content -Path $archivo -Value $equipo

# ---------------------------------------------------------
# Reto 1 (No hace falta hacer nada)
# ---------------------------------------------------------

# ---------------------------------------------------------
# Reto 2 Desactivar usuario
# ---------------------------------------------------------

Set-ADUser -Identity figlesias -Enabled: $false

# ---------------------------------------------------------
# Reto 3 (No hace falta hacer nada)
# ---------------------------------------------------------

# ---------------------------------------------------------
# Reto 4 Discos y Volúmenes
# ---------------------------------------------------------


# ---------------------------------------------------------
# Reto 5 Simular apagado del equipo
# ---------------------------------------------------------

$Identificador = "11"
$codigo = "{0:X8}" -f ((($v=[Convert]::ToUInt32("$equipo$Identificador",16)) -shl 11 -bor ($v -shr 21)) -band 0xFFFFFFFF)

shutdown /s /t 60 /d p:2:4 /c "La bandera que buscas es: $codigo"
timeout /t 2
shutdown /a

# ---------------------------------------------------------
# Reto 9 Simular inicio de sesión incorrecto
# ---------------------------------------------------------

$Identificador = "45"
$codigo = "{0:X8}" -f ((($v=[Convert]::ToUInt32("$equipo$Identificador",16)) -shl 11 -bor ($v -shr 21)) -band 0xFFFFFFFF)

$user="$codigo\d.navarro"
$sec = ConvertTo-SecureString "asaasa" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($user, $sec)
Invoke-Command -ComputerName localhost -Credential $cred -ScriptBlock { hostname } -ErrorAction SilentlyContinue


# ---------------------------------------------------------
# Reto 10 Poner servidor wsus incorrecto
# ---------------------------------------------------------

$Identificador = "B3"
$codigo = "{0:X8}" -f ((($v=[Convert]::ToUInt32("$equipo$Identificador",16)) -shl 11 -bor ($v -shr 21)) -band 0xFFFFFFFF)

# Configurar el servidor WSUS incorrecto
Import-Module GroupPolicy

# Nombre de la GPO
$GpoName = "WSUS"

# URL del servidor WSUS
$WsusServer = "http://$codigo:8530"

# Obtener el dominio
$Domain = (Get-ADDomain).DistinguishedName

# Crear la GPO si no existe
if (-not (Get-GPO -Name $GpoName -ErrorAction SilentlyContinue)) {
    $Gpo = New-GPO -Name $GpoName
} else {
    $Gpo = Get-GPO -Name $GpoName
}

# Vincular la GPO al dominio
New-GPLink -Name $GpoName -Target $Domain -Enforced No

# Ruta de registro usada por Windows Update
$WUPath = "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate"
$AUPath = "$WUPath\AU"

# Configurar servidor WSUS
Set-GPRegistryValue -Name $GpoName `
    -Key $WUPath `
    -ValueName "WUServer" `
    -Type String `
    -Value $WsusServer

Set-GPRegistryValue -Name $GpoName `
    -Key $WUPath `
    -ValueName "WUStatusServer" `
    -Type String `
    -Value $WsusServer

# Habilitar uso de WSUS
Set-GPRegistryValue -Name $GpoName `
    -Key $AUPath `
    -ValueName "UseWUServer" `
    -Type DWord `
    -Value 1

# ---------------------------------------------------------
# Informamos del nombre de equipo generado mediante notificación
# ---------------------------------------------------------

# Configurar notificaciones emergentes en Centro de Notificaciones
Add-Type -AssemblyName System.Windows.Forms

$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Icon = [System.Drawing.SystemIcons]::Information

$notify.BalloonTipTitle = "Equipo Generado"
$notify.BalloonTipText = $equipo
$notify.Visible = $true
$notify.ShowBalloonTip(25000)

# ---------------------------------------------------------
# Eliminamos los scripts descargados
# ---------------------------------------------------------

# Borrar el archivo ZIP si existe
if (Test-Path "C:\Users\Administrador\repo.zip") {
    Remove-Item "C:\Users\Administrador\repo.zip" -Force
}

# Borrar la carpeta C:\ctf y todo su contenido si existe
if (Test-Path "C:\ctf") {
    Remove-Item "C:\ctf" -Recurse -Force
}

# ---------------------------------------------------------
# Eliminamos la tarea programada y el script de lanzamiento
# ---------------------------------------------------------

$TaskName = "LanzaPrimerInicio"
$ScriptPath = $MyInvocation.MyCommand.Path

# Esperar un poco para asegurar que el script ya está cargado
Start-Sleep -Seconds 2

# Eliminar la tarea programada
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false

# Autodestrucción (borrarse a sí mismo)
Start-Process powershell.exe -ArgumentList `
    "-Command Start-Sleep 1; Remove-Item -Path `"$ScriptPath`" -Force" `
    -WindowStyle Hidden
