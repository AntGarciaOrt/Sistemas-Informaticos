$domain = "DC=HospitaFrancescBorjaDeGandia,DC=mylocal"

$equiposCsv = "C:\CSVs\equipos.csv"

$fichero = Import-Csv -Path $equiposCsv -Delimiter ':'

foreach ($line in $fichero)
{
    # CORRECCIÓN: try/catch para que un duplicado no detenga el resto
    try {
        New-ADComputer `
            -Name    $line.Computer `
            -Path    $line.Path `
            -Enabled $true

        Write-Host "Equipo '$($line.Computer)' creado correctamente." -ForegroundColor Green
    }
    catch {
        Write-Warning "Error al crear el equipo '$($line.Computer)': $_"
    }
}

Write-Host ""
Write-Host "Se han creado los equipos en el dominio $domain" -ForegroundColor Green
Write-Host ""
