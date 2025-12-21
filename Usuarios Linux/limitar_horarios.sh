#!/bin/bash

# Activar módulo pam_time en common-auth
AUTH_FILE="/etc/pam.d/common-auth"
if ! grep -q "pam_time.so" "$AUTH_FILE"; then
    echo "account required pam_time.so" | sudo tee -a "$AUTH_FILE"
fi

# Añadir reglas de horario en /etc/security/time.conf
TIME_CONF="/etc/security/time.conf"

# Crear archivo si no existe
sudo touch "$TIME_CONF"

# Reglas para Alergología: todos los días de 09:00 a 14:00 y de 16:00 a 19:00
echo "login ; * ; alergologia ; Al0900-1400 | Al1600-1900" | sudo tee -a "$TIME_CONF"

# Reglas para Informática: día 15 de 07:00 a 15:00, día 10 de 15:00 a 23:00
echo "login ; * ; informatica ; Wk15 0700-1500" | sudo tee -a "$TIME_CONF"
echo "login ; * ; informatica ; Wk10 1500-2300" | sudo tee -a "$TIME_CONF"
echo "Restricciones horarias aplicadas correctamente."