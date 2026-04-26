$domain = "DC=HospitaFrancescBorjaDeGandia,DC=mylocal"

if (!(Get-Module -Name ActiveDirectory)) {
    Import-Module ActiveDirectory
}

$fileUsersCsv = "C:\CSVs\usuarios.csv"

$fichero = Import-Csv -Path $fileUsersCsv -Delimiter '*'

foreach ($linea in $fichero)
{
    $passAccount = ConvertTo-SecureString $linea.Password -AsPlainText -Force

    # CORRECCIÓN: nombres de variables corregidos (estaban intercambiados)
    $Surname     = "$($linea.FirstName) $($linea.LastName)"
    $DisplayName = "$($linea.Name) $($linea.FirstName) $($linea.LastName)"
    $email       = $linea.Email

    $Habilitado = $true
    if ($linea.Enabled -match 'false') { $Habilitado = $false }

    $timeExp = (Get-Date).AddDays([int]$linea.ExpirationAccount)

    # CORRECCIÓN: UserPrincipalName con dominio completo
    $upn = "$($linea.Account)@HospitaFrancescBorjaDeGandia.mylocal"

    try {
        New-ADUser `
            -SamAccountName      $linea.Account `
            -UserPrincipalName   $upn `
            -Name                $linea.Account `
            -Surname             $Surname `
            -DisplayName         $DisplayName `
            -GivenName           $linea.Name `
            -Description         "Cuenta de $DisplayName" `
            -EmailAddress        $email `
            -AccountPassword     $passAccount `
            -Enabled             $Habilitado `
            -CannotChangePassword $false `
            -ChangePasswordAtLogon $true `
            -PasswordNotRequired  $false `
            -Path                $linea.Path `
            -AccountExpirationDate $timeExp `
            -LogonWorkstations   $linea.computer

        # Horario de sesión
        $horassesion = $linea.NetTime -replace(" ", "")
        net user $linea.Account /times:$horassesion

        # CORRECCIÓN: Add-ADGroupMember con manejo de error para no interrumpir el bucle
        try {
            Add-ADGroupMember -Identity $linea.Group -Members $linea.Account
        }
        catch {
            Write-Warning "No se pudo añadir '$($linea.Account)' al grupo '$($linea.Group)': $_"
        }

        Write-Host "Usuario '$($linea.Account)' creado correctamente." -ForegroundColor Green
    }
    catch {
        Write-Warning "Error al crear el usuario '$($linea.Account)': $_"
    }
}

Write-Host ""
Write-Host "Proceso finalizado en el dominio $domain" -ForegroundColor Green
Write-Host ""
