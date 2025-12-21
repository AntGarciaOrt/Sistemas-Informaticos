#!/bin/bash

USUARIOS="bpujolg mjuanv ichavesv itest"

for u in $USUARIOS; do
    sudo mkdir -p /var/lib/AccountsService/users
    echo -e "[User]\nSystemAccount=true" | sudo tee /var/lib/AccountsService/users/$u
done

sudo systemctl restart gdm3

echo "Usuarios ocultados en Ubuntu (GDM)."