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
