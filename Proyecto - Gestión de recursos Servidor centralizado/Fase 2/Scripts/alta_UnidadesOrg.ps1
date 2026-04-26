$domain = "DC=HospitaFrancescBorjaDeGandia,DC=mylocal"

if (!(Get-Module -Name ActiveDirectory)) {
    Import-Module ActiveDirectory
}

$ficheroCsvUO = "C:\CSVs\unidades_org.csv"

$fichero = Import-Csv -Path $ficheroCsvUO -Delimiter ':'

foreach ($line in $fichero)
{
    # 1. Crear la OU principal del departamento
    try {
        New-ADOrganizationalUnit `
            -Name                            $line.Name `
            -Description                     $line.Description `
            -Path                            $line.Path `
            -ProtectedFromAccidentalDeletion  $true

        Write-Host "OU '$($line.Name)' creada correctamente." -ForegroundColor Green
    }
    catch {
        Write-Warning "Error al crear la OU '$($line.Name)': $_"
    }

    # 2. Crear sub-OUs Usuarios y Equipos dentro de la OU recien creada
    $parentPath = "OU=$($line.Name),$($line.Path)"

    foreach ($subOU in @("Usuarios", "Equipos"))
    {
        $existe = Get-ADOrganizationalUnit `
            -Filter      { Name -eq $subOU } `
            -SearchBase  $parentPath `
            -SearchScope OneLevel `
            -ErrorAction SilentlyContinue

        if ($existe) {
            Write-Host "  Sub-OU '$subOU' ya existe en '$parentPath', se omite." -ForegroundColor Yellow
        } else {
            try {
                New-ADOrganizationalUnit `
                    -Name                            $subOU `
                    -Description                     "$subOU de $($line.Name)" `
                    -Path                            $parentPath `
                    -ProtectedFromAccidentalDeletion  $true

                Write-Host "  Sub-OU '$subOU' creada dentro de '$parentPath'." -ForegroundColor Green
            }
            catch {
                Write-Warning "  Error al crear sub-OU '$subOU' en '$parentPath': $_"
            }
        }
    }
}

Write-Host ""
Write-Host "UOs y sub-OUs creadas satisfactoriamente en el dominio $domain" -ForegroundColor Green
Write-Host ""
