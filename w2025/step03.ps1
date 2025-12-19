 Import-Module ActiveDirectory

$DominioDN = "DC=cerezo,DC=asir"
$RutaCSV = ".\usuarios.csv"

# OUs a crear
$OUs = @(
    "Ventas",
    "IT",
    "RRHH",
    "Finanzas",
    "Direccion"
)

# Crear OUs
foreach ($OU in $OUs) {
    $OUPath = "OU=$OU,$DominioDN"
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OUPath'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $OU -Path $DominioDN
        Write-Host "OU creada: $OU"
    }
}

# Importar usuarios
$Usuarios = Import-Csv $RutaCSV

# Crear grupos únicos
$Grupos = $Usuarios | Select-Object -ExpandProperty Grupo -Unique

foreach ($Grupo in $Grupos) {
    if (-not (Get-ADGroup -Filter "Name -eq '$Grupo'" -ErrorAction SilentlyContinue)) {
        New-ADGroup `
            -Name $Grupo `
            -GroupScope Global `
            -GroupCategory Security `
            -Path "CN=Users,$DominioDN" `
            -ErrorAction SilentlyContinue
        Write-Host "Grupo creado: $Grupo"
    }
}

# Crear OU Grupos si no existe
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Grupos'" -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "Grupos" -Path $DominioDN
}

# Crear usuarios y añadirlos a grupos
foreach ($User in $Usuarios) {


    $OUPath = "$($User.OU),$DominioDN"

    $Password = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($User.Usuario)'" -ErrorAction SilentlyContinue)) {

        New-ADUser `
            -Name "$($User.Nombre) $($User.Apellido)" `
            -GivenName $User.Nombre `
            -Surname $User.Apellido `
            -SamAccountName $User.Usuario `
            -UserPrincipalName "$($User.Usuario)@cerezo.asir" `
            -Department $User.Departamento `
            -Path $OUPath `
            -AccountPassword $Password `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "Usuario creado: $($User.Usuario)"
    }

    Add-ADGroupMember -Identity $User.Grupo -Members $User.Usuario -ErrorAction SilentlyContinue
}

