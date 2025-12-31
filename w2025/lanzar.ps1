Import-Module ActiveDirectory

# ---------------------------------------------------------
# Generamos código del equipo y lo dejamos en el escritorio
# ---------------------------------------------------------

# Generar cadena hexadecimal aleatoria (6 caracteres)
$hex = -join ((0..5) | ForEach-Object { '{0:X}' -f (Get-Random -Maximum 16) })

# Ruta del escritorio del usuario (perfil por defecto)
$desktopPath = "$env:USERPROFILE\Desktop"

# Crear el fichero equipo.txt
$archivo = Join-Path $desktopPath "equipo.txt"
Set-Content -Path $archivo -Value $hex



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
