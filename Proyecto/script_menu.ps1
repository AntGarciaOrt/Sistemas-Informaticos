function fntFuncion1 {
    Write-Host "Creando usuarios y grupos..."

    $grupos = @("1ESO", "2ESO", "3ESO", "4ESO", "1BATCH", "2BATCH", "1DAW", "alumnado", "profesorado", "administrador")
    foreach ($grupo in $grupos) {
        if (-not (Get-LocalGroup -Name $grupo -ErrorAction SilentlyContinue)) {
            New-LocalGroup -Name $grupo
            Write-Host "Grupo creado: $grupo"
        }
    }

    $usuarios = @(
        @{Nombre="user1ESO"; Grupo="1ESO"},
        @{Nombre="user2ESO"; Grupo="2ESO"},
        @{Nombre="user3ESO"; Grupo="3ESO"},
        @{Nombre="user4ESO"; Grupo="4ESO"},
        @{Nombre="user1BATCH"; Grupo="1BATCH"},
        @{Nombre="user2BATCH"; Grupo="2BATCH"},
        @{Nombre="user1DAW"; Grupo="1DAW"},
        @{Nombre="admin"; Grupo="administrador"}
    )

    foreach ($usuario in $usuarios) {
        $nombre = $usuario.Nombre
        $grupo = $usuario.Grupo
        if (-not (Get-LocalUser -Name $nombre -ErrorAction SilentlyContinue)) {
            $password = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force
            New-LocalUser -Name $nombre -Password $password -FullName $nombre
            Add-LocalGroupMember -Group $grupo -Member $nombre
            Write-Host "Usuario creado: $nombre en grupo $grupo"
        }
    }

        if (-not (Get-LocalGroupMember -Group "Administradores" -ErrorAction SilentlyContinue |
              Where-Object { $_.Name -like "*1DAW" })) {

        Add-LocalGroupMember -Group "Administradores" -Member "1DAW"
        Write-Host "El grupo 1DAW ahora tiene permisos de administrador"
    }
}

function fntFuncion2 {
    Write-Host "Creando estructura de directorios y asignando permisos..."

    $basePath = "C:\GestorDocumental"

    $estructura = @{
        "ESO"  = @("1ESO", "2ESO", "3ESO", "4ESO")
        "BACH" = @("1BATCH", "2BATCH")
        "DAW"  = @("1DAW")
    }

    foreach ($nivel in $estructura.Keys) {
        $rutaNivel = Join-Path $basePath $nivel

        if (-not (Test-Path $rutaNivel)) {
            New-Item -Path $rutaNivel -ItemType Directory
            Write-Host "Carpeta creada: $rutaNivel"
        }

        foreach ($carpeta in $estructura[$nivel]) {
            $rutaCurso = Join-Path $rutaNivel $carpeta

            if (-not (Test-Path $rutaCurso)) {
                New-Item -Path $rutaCurso -ItemType Directory
                Write-Host "Carpeta creada: $rutaCurso"
            }
        }
    }

    # Permisos ESO (solo lectura)
    foreach ($curso in @("1ESO", "2ESO", "3ESO", "4ESO")) {
        $ruta = "$basePath\ESO\$curso"
        icacls $ruta /grant "1ESO:R" /grant "2ESO:R" /grant "3ESO:R" /grant "4ESO:R" /inheritance:e
    }

    # Permisos BACH (solo lectura)
    foreach ($curso in @("1BATCH", "2BATCH")) {
        $ruta = "$basePath\BACH\$curso"
        icacls $ruta /grant "1BATCH:R" /grant "2BATCH:R" /inheritance:e
    }

    Write-Host "Estructura y permisos aplicados correctamente"
}

function mostrar_Submenu {
    param (
        [string]$Titulo = 'Submenu.....'
    )
    Clear-Host 
    Write-Host "================ $Titulo ================"
    Write-Host "1: Opción 1."
    Write-Host "2: Opción 2."
    Write-Host "s: Volver al menu principal."

    do {
        $input = Read-Host "Por favor, pulse una opcion"
        switch ($input) {
            '1' { Write-Host "Opción 1 seleccionada"; return }
            '2' { Write-Host "Opción 2 seleccionada"; return }
            's' { return }
        }
    } until ($input -eq 's')
}

function mostrarMenu { 
    param ( 
        [string]$Titulo = 'Seleccion de opciones' 
    ) 
    Clear-Host 
    Write-Host "================ $Titulo ================" 
    Write-Host "1. Crear usuarios y grupos" 
    Write-Host "2. Crear estructura y permisos" 
    Write-Host "3. Submenu" 
    Write-Host "s. Presiona 's' para salir" 
}

do { 
    mostrarMenu 
    $input = Read-Host "Elegir una Opcion" 
    switch ($input) { 
        '1' { Clear-Host; fntFuncion1; pause }
        '2' { Clear-Host; fntFuncion2; pause }
        '3' { mostrar_Submenu }
        's' { Write-Host "Saliendo del script..."; return }  
    } 
    pause 
} until ($input -eq 's')
