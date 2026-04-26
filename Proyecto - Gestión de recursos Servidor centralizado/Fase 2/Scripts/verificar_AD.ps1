$domain = "DC=HospitaFrancescBorjaDeGandia,DC=mylocal"

if (!(Get-Module -Name ActiveDirectory)) {
    Import-Module ActiveDirectory
}

$sep = "=" * 60

# UOs (excluye Domain Controllers que es del sistema)
Write-Host ""
Write-Host $sep -ForegroundColor Cyan
Write-Host "  UNIDADES ORGANIZATIVAS" -ForegroundColor Cyan
Write-Host $sep -ForegroundColor Cyan

$ous = Get-ADOrganizationalUnit -Filter * -SearchBase $domain |
    Where-Object { $_.DistinguishedName -notlike "*Domain Controllers*" } |
    Select-Object Name, DistinguishedName

if ($ous) {
    $ous | ForEach-Object {
        Write-Host "  [OK] $($_.Name)" -ForegroundColor Green
        Write-Host "       $($_.DistinguishedName)" -ForegroundColor Gray
    }
} else {
    Write-Host "  [!] No se encontraron UOs" -ForegroundColor Red
}

# GRUPOS (solo los creados por los scripts SI-GG-*)
Write-Host ""
Write-Host $sep -ForegroundColor Cyan
Write-Host "  GRUPOS" -ForegroundColor Cyan
Write-Host $sep -ForegroundColor Cyan

$grupos = Get-ADGroup -Filter * -SearchBase $domain |
    Where-Object { $_.Name -like "SI-GG-*" } |
    Select-Object Name, GroupScope, GroupCategory

if ($grupos) {
    $grupos | ForEach-Object {
        Write-Host "  [OK] $($_.Name)  [$($_.GroupScope) / $($_.GroupCategory)]" -ForegroundColor Green
    }
} else {
    Write-Host "  [!] No se encontraron grupos" -ForegroundColor Red
}

# USUARIOS (excluye cuentas del sistema)
Write-Host ""
Write-Host $sep -ForegroundColor Cyan
Write-Host "  USUARIOS" -ForegroundColor Cyan
Write-Host $sep -ForegroundColor Cyan

$usuarios = Get-ADUser -Filter * -SearchBase $domain -Properties DisplayName, EmailAddress, Enabled, DistinguishedName, MemberOf, AccountExpirationDate, LogonWorkstations |
    Where-Object {
        $_.SamAccountName -ne "Administrator" -and
        $_.SamAccountName -ne "krbtgt" -and
        $_.SamAccountName -ne "Invitado" -and
        $_.SamAccountName -ne "Administrador" -and
        $_.DistinguishedName -notlike "*CN=Users*"
    }

if ($usuarios) {
    foreach ($u in $usuarios) {
        $estado = if ($u.Enabled) { "Habilitado" } else { "Deshabilitado" }
        $color  = if ($u.Enabled) { "Green" } else { "Yellow" }
        $grupos_u = ($u.MemberOf | ForEach-Object { ($_ -split ',')[0] -replace 'CN=','' }) -join ", "
        Write-Host "  [OK] $($u.SamAccountName) - $($u.DisplayName)" -ForegroundColor $color
        Write-Host "       Estado:  $estado" -ForegroundColor Gray
        Write-Host "       Email:   $($u.EmailAddress)" -ForegroundColor Gray
        Write-Host "       Grupos:  $grupos_u" -ForegroundColor Gray
        Write-Host "       Expira:  $($u.AccountExpirationDate)" -ForegroundColor Gray
        Write-Host "       Equipo:  $($u.LogonWorkstations)" -ForegroundColor Gray
        Write-Host "       OU:      $(($u.DistinguishedName -split ',',2)[1])" -ForegroundColor Gray
        Write-Host ""
    }
} else {
    Write-Host "  [!] No se encontraron usuarios" -ForegroundColor Red
}

# EQUIPOS (excluye el controlador de dominio)
Write-Host ""
Write-Host $sep -ForegroundColor Cyan
Write-Host "  EQUIPOS" -ForegroundColor Cyan
Write-Host $sep -ForegroundColor Cyan

$equipos = Get-ADComputer -Filter * -SearchBase $domain -Properties Enabled, DistinguishedName |
    Where-Object { $_.DistinguishedName -notlike "*Domain Controllers*" }

if ($equipos) {
    foreach ($e in $equipos) {
        $estado = if ($e.Enabled) { "Habilitado" } else { "Deshabilitado" }
        $color  = if ($e.Enabled) { "Green" } else { "Yellow" }
        Write-Host "  [OK] $($e.Name) - $estado" -ForegroundColor $color
        Write-Host "       OU: $(($e.DistinguishedName -split ',',2)[1])" -ForegroundColor Gray
    }
} else {
    Write-Host "  [!] No se encontraron equipos" -ForegroundColor Red
}

