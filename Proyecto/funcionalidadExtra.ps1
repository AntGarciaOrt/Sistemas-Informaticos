function fntInformeActividad {
    Clear-Host
    $basePath = "C:\GestorDocumental"
    $logPath = "C:\GestorDocumental\informes"
    if (-not (Test-Path $logPath)) { New-Item -Path $logPath -ItemType Directory }

    $fecha = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $informe = "$logPath\informe_$fecha.txt"

    Add-Content $informe "===== INFORME DE ACTIVIDAD ====="
    Add-Content $informe "Fecha: $(Get-Date)"
    Add-Content $informe ""

    # Tamaño de carpetas
    Add-Content $informe ">> Tamaño de carpetas:"
    Get-ChildItem $basePath | ForEach-Object {
        $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Add-Content $informe "$($_.Name): $([math]::Round($size/1MB,2)) MB"
    }

    Add-Content $informe ""
    Add-Content $informe ">> Últimos accesos registrados:"
    wevtutil qe Security /q:"*[System[(EventID=4663)]]" /c:20 /f:text | Add-Content $informe

    Write-Host "Informe generado en: $informe"
}
