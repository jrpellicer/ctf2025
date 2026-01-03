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
    -Size 197GB
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
