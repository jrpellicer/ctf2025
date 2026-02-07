# ==================================================
# CONFIGURACIÓN DEL SERVIDOR WINDOWS SERVER 2025
# ==================================================

# Datos de red
$IP = "192.168.10.25"
$Prefijo = 24
$Gateway = "192.168.10.1"
$DNS = @("127.0.0.1")

# Nombre del controlador de dominio
$NombreEquipo = "SRV-25-DC01"

# Dominio
$Dominio = "asir.iescamp.es"
$NetBIOS = "ASIR"
$DominioDN = "DC=asir,DC=iescamp,DC=es"

# Contraseña DSRM (modo restauración)
$DSRMPassword = ConvertTo-SecureString "qwe_123" -AsPlainText -Force

# Usuario para jugar
$usuario = "adminsistema"
$nombreCompleto = "adminsistema"
$password = ConvertTo-SecureString "qwe_123" -AsPlainText -Force

