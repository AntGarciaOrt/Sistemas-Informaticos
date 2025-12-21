#!/bin/bash
# Crear grupos de departamentos desde departamentos.csv
while IFS=',' read -r nombre descripcion; do
    if [ -n "$nombre" ] && [ "$nombre" != "nombre" ]; then
        if getent group "$nombre" > /dev/null; then
            echo "Grupo '$nombre' ya existe. Saltando..."
        else
            echo "Creando grupo: $nombre"
            groupadd "$nombre"
        fi
    fi
done < departamentos.csv

# Crear usuarios desde usuarios.csv
while IFS=',' read -r login password nombre_apellidos descripcion grupo_departamento grupo_personal horario; do
    if [ -n "$login" ] && [ "$login" != "login" ]; then

        # Crear grupo personal si no existe
        if ! getent group "$grupo_personal" > /dev/null; then
            echo "Creando grupo personal: $grupo_personal"
            groupadd "$grupo_personal"
        fi

        # Crear usuario si no existe
        if id "$login" &>/dev/null; then
            echo "Usuario '$login' ya existe. Saltando..."
        else
            echo "Creando usuario: $login"

            # Limpiar comentario para evitar errores
            comentario="$(echo "${descripcion} Horario ${horario}" | tr -cd '[:alnum:] ._-')"

            useradd -m \
                -c "$comentario" \
                -g "$grupo_personal" \
                -G "$grupo_departamento" \
                "$login"

            # Verificar que el usuario existe antes de asignar contrasena
            if id "$login" &>/dev/null; then
                echo "$login:$password" | chpasswd
            else
                echo "No se pudo crear el usuario $login. Saltando contrasena."
            fi
        fi
    fi
done < usuarios.csv
echo "Proceso completado."