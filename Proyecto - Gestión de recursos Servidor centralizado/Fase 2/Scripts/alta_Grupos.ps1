$domain = "DC=HospitaFrancescBorjaDeGandia,DC=mylocal"

$gruposCsv = "C:\CSVs\grupos.csv"

$fichero = Import-Csv -Path $gruposCsv -Delimiter ':'

foreach ($linea in $fichero)
{
    # CORRECCIÓN: try/catch para que un duplicado no detenga el resto
    try {
        New-ADGroup `
            -Name          $linea.Name `
            -Description   $linea.Description `
            -GroupCategory $linea.Category `
            -GroupScope    $linea.Scope `
            -Path          $linea.Path

        Write-Host "Grupo '$($linea.Name)' creado correctamente." -ForegroundColor Green
    }
    catch {
        Write-Warning "Error al crear el grupo '$($linea.Name)': $_"
    }
}

Write-Host ""
Write-Host "Se han creado los grupos en el dominio $domain" -ForegroundColor Green
Write-Host ""
