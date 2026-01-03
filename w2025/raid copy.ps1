# Prueba de creación de RAID 1 con dos discos virtuales
# 1. Definir la ruta del disco virtual y el archivo de comandos temporal
$vhd1Path = "C:\DiscosVirtuales\Disco1.vhdx"
$vhd2Path = "C:\DiscosVirtuales\Disco2.vhdx"
$vhd3Path = "C:\DiscosVirtuales\Disco3.vhdx"

$scriptFile = "$env:TEMP\diskpart_script.txt"

# 2. Crear la lista de comandos para Diskpart
# Se usa el formato de array para facilitar la lectura
$commands = @(
    "create vdisk file=`"$vhd1Path`" maximum=10240 type=expandable",
    "select vdisk file=`"$vhd1Path`"",
    "attach vdisk",
    "exit"
)

# 3. Guardar los comandos en el archivo de texto
$commands | Out-File -FilePath $scriptFile -Encoding ASCII -Force

# 4. Ejecutar Diskpart con el script creado
Start-Process diskpart.exe -ArgumentList "/s $scriptFile" -Wait -NoNewWindow

# 2. Crear la lista de comandos para Diskpart
# Se usa el formato de array para facilitar la lectura
$commands = @(
    "create vdisk file=`"$vhd2Path`" maximum=10240 type=expandable",
    "select vdisk file=`"$vhd2Path`"",
    "attach vdisk",
    "exit"
)
# 3. Guardar los comandos en el archivo de texto
$commands | Out-File -FilePath $scriptFile -Encoding ASCII -Force

# 4. Ejecutar Diskpart con el script creado
Start-Process diskpart.exe -ArgumentList "/s $scriptFile" -Wait -NoNewWindow

$disks = Get-PhysicalDisk | Where-Object CanPool -eq $true

New-StoragePool `
    -FriendlyName "PoolRAID" `
    -StorageSubsystemFriendlyName "Windows Storage*" `
    -PhysicalDisks $disks

New-VirtualDisk `
    -StoragePoolFriendlyName "PoolRAID" `
    -FriendlyName "VolMirror" `
    -ResiliencySettingName Mirror `
    -Size 5GB

$vdisk = Get-VirtualDisk -FriendlyName "VolMirror"
$disk  = Get-Disk | Where-Object FriendlyName -eq $vdisk.FriendlyName

Initialize-Disk $disk.Number -PartitionStyle GPT

New-Partition `
    -DiskNumber $disk.Number `
    -UseMaximumSize `
    -DriveLetter R

Format-Volume `
    -DriveLetter R `
    -FileSystem NTFS `
    -NewFileSystemLabel "RAID1_VIRTUAL" `
    -Confirm:$false


# 2. Crear la lista de comandos para Diskpart
# Se usa el formato de array para facilitar la lectura
$commands = @(
    "create vdisk file=`"$vhd3Path`" maximum=10240 type=expandable",
    "select vdisk file=`"$vhd3Path`"",
    "attach vdisk",
    "create partition primary",
    "format fs=ntfs quick label=`"DiscoVirtual`"",
    "assign letter=V",
    "exit"
)

# 3. Guardar los comandos en el archivo de texto
$commands | Out-File -FilePath $scriptFile -Encoding ASCII -Force

# 4. Ejecutar Diskpart con el script creado
Start-Process diskpart.exe -ArgumentList "/s $scriptFile" -Wait -NoNewWindow

# 5. Limpiar el archivo temporal
Remove-Item $scriptFile
