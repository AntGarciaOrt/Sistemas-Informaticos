$domain = "DC=HospitaFrancescBorjaDeGandia,DC=mylocal"

# Ruta base donde esta este script
$basePath = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Show-Menu
{
    param ([string]$Titulo = 'Menu principal')
    Clear-Host
    Write-Host "================ $Titulo ================"
    Write-Host "1: Crear UOs (incluye sub-OUs Usuarios y Equipos)"
    Write-Host "2: Crear Grupos"
    Write-Host "3: Crear Usuarios"
    Write-Host "4: Crear Equipos"
    Write-Host "Q: Salir"
    Write-Host ""
    Write-Host "Orden recomendado: 1 -> 2 -> 3 -> 4" -ForegroundColor Cyan
}

function alta_UOs
{
    $script = "$basePath\alta_UnidadesOrg.ps1"
    Write-Host "Lanzando: $script"
    if (Test-Path $script) {
        & $script
        Write-Host "Script ejecutado"
    } else {
        Write-Host "ERROR: No se encuentra el script" -ForegroundColor Red
    }
}

function alta_grupos
{
    $script = "$basePath\alta_Grupos.ps1"
    if (Test-Path $script) {
        Write-Host "Ejecutando Grupos..."
        & $script
    } else {
        Write-Host "ERROR: No se encuentra $script" -ForegroundColor Red
    }
}

function alta_usuarios
{
    $script = "$basePath\alta_Usuarios.ps1"
    if (Test-Path $script) {
        Write-Host "Ejecutando Usuarios..."
        & $script
    } else {
        Write-Host "ERROR: No se encuentra $script" -ForegroundColor Red
    }
}

function alta_equipos
{
    $script = "$basePath\alta_equipos.ps1"
    if (Test-Path $script) {
        Write-Host "Ejecutando Equipos..."
        & $script
    } else {
        Write-Host "ERROR: No se encuentra $script" -ForegroundColor Red
    }
}

# Cargar modulo Active Directory si no esta cargado
if (!(Get-Module -Name ActiveDirectory))
{
    Import-Module ActiveDirectory
}

# MENU PRINCIPAL
do
{
    Show-Menu
    $opcion = Read-Host "Selecciona una opcion"

    switch ($opcion)
    {
        '1' { alta_UOs }
        '2' { alta_grupos }
        '3' { alta_usuarios }
        '4' { alta_equipos }
        { $_ -eq 'q' -or $_ -eq 'Q' } { Write-Host "Saliendo..." }
        default { Write-Host "Opcion no valida" -ForegroundColor Yellow }
    }

    if ($opcion -ne 'q' -and $opcion -ne 'Q') { Pause }
}
until ($opcion -eq 'q' -or $opcion -eq 'Q')
