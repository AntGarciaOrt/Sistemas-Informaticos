#!/bin/bash

# Ruta donde está montado el NAS
BASE_DIR="/mnt/sistemaImagenes"

# Fecha actual
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)

# Carpetas principales
DIRECTORIOS=("observacion" "prediccion" "webcam")

# Crear estructura
for DIR in "${DIRECTORIOS[@]}"; do
    # Ruta de la carpeta principal
    DIR_PATH="$BASE_DIR/$DIR/$YEAR/$MONTH/$DAY"
    mkdir -p "$DIR_PATH"  # crea la carpeta si no existe, no hace nada si ya existe

    # Crear la misma estructura dentro de registro_log
    REG_LOG_PATH="$BASE_DIR/registro_log/$DIR/$YEAR/$MONTH/$DAY"
    mkdir -p "$REG_LOG_PATH"
done
