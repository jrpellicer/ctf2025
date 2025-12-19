# ==================================================
# CONFIGURACIÓN
# ==================================================

# Dominio
$Dominio = "cerezo.asir"
$NetBIOS = "CEREZO"

# Contraseña DSRM (modo restauración)
$DSRMPassword = ConvertTo-SecureString "qwe_123" -AsPlainText -Force

# ==================================================
# INSTALAR AD DS
# ==================================================

Write-Host "Instalando rol AD Domain Services..." -ForegroundColor Yellow

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# ==================================================
# CREAR DOMINIO
# ==================================================

Write-Host "Creando dominio $Dominio..." -ForegroundColor Yellow

Install-ADDSForest `
    -DomainName $Dominio `
    -DomainNetbiosName $NetBIOS `
    -SafeModeAdministratorPassword $DSRMPassword `
    -InstallDns `
    -Force

# ==================================================
# FIN (reinicio automático)
# ==================================================

Write-Host "El servidor se reiniciará para completar la instalación." -ForegroundColor Green

