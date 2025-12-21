#!/bin/bash
echo "=== Configurando política de contraseñas en Linux ==="

# 1. Configurar caducidad de contraseñas
echo "→ Estableciendo caducidad de 30 días..."
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   30/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   0/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs

# 2. Configurar complejidad y longitud mínima
echo "→ Configurando complejidad y longitud mínima..."
if grep -q "pam_pwquality.so" /etc/pam.d/common-password 2>/dev/null; then
    sed -i 's/^password.*pam_pwquality.so.*/password requisite pam_pwquality.so retry=3 minlen=10 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password
else
    echo "password requisite pam_pwquality.so retry=3 minlen=10 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1" >> /etc/pam.d/common-password
fi

# 3. Evitar reutilización de últimas 5 contraseñas
echo "→ Configurando historial de contraseñas..."
if grep -q "remember=" /etc/pam.d/common-password 2>/dev/null; then
    sed -i 's/remember=[0-9]*/remember=5/' /etc/pam.d/common-password
else
    sed -i 's/pam_unix.so/& remember=5/' /etc/pam.d/common-password
fi

# 4. Bloqueo tras 4 intentos fallidos durante 1 hora
echo "→ Configurando bloqueo de cuenta tras 4 intentos fallidos..."
if ! grep -q "pam_faillock.so" /etc/pam.d/common-auth 2>/dev/null; then
    echo "auth required pam_faillock.so preauth silent deny=4 unlock_time=3600" >> /etc/pam.d/common-auth
    echo "auth [success=1 default=bad] pam_unix.so" >> /etc/pam.d/common-auth
    echo "auth [default=die] pam_faillock.so authfail deny=4 unlock_time=3600" >> /etc/pam.d/common-auth
    echo "account required pam_faillock.so" >> /etc/pam.d/common-account
fi

# 5. Contraseña por defecto para nuevos usuarios (obligar cambio)
echo "→ Configurando contraseña por defecto para nuevos usuarios..."
DEFAULT_PASS="Cambiar123!"
echo "Contraseña por defecto establecida: $DEFAULT_PASS"
echo "→ Para cada nuevo usuario, ejecutar:"
echo "  useradd <usuario>"
echo "  echo \"<usuario>:${DEFAULT_PASS}\" | chpasswd"
echo "  chage -d 0 <usuario>   # Obliga a cambiar contraseña en el primer login"
echo "=== Configuración completada ==="

