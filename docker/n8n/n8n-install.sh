#!/bin/bash

scripts=(
   "check-disk-space.sh"
   "check-or-install-docker.sh"
   "check-ram.sh"
   "install-docker-engine-on-ubuntu.sh"
)

for script in "${scripts[@]}"; do
   script_name="${script%.sh}"
   sudo curl -fsSL "https://raw.githubusercontent.com/ktutak1337/Boilerplates-Public/refs/heads/main/scripts/${script}" -o "/usr/bin/${script_name}"
   sudo chmod +x "/usr/bin/${script_name}"
done

source check-ram 1024 || exit 1

source check-disk-space 1 || exit 1

source check-or-install-docker

mkdir -p $HOME/docker/n8n/{db,data}


app_files=(
   "docker-compose.yml"
   "init-data.sh"
   "n8n-install.sh"
   "setup-env.sh"
)

curl -fsSL "https://raw.githubusercontent.com/ktutak1337/Boilerplates-Public/refs/heads/main/docker/n8n/.env.example" -o "${HOME}/docker/n8n/.env"

for script in "${app_files[@]}"; do
   curl -fsSL "https://raw.githubusercontent.com/ktutak1337/Boilerplates-Public/refs/heads/main/docker/n8n/${script}" -o "${HOME}/docker/n8n/${script}"
done

sudo chmod +x ${HOME}/docker/n8n/*.sh
sudo chown $USER:$USER -R ${HOME}/docker/n8n

cd ${HOME}/docker/n8n
source ./setup-env.sh

# Sprawdź czy sieć istnieje, jeśli nie to ją utwórz
docker network ls --format "{{.Name}}" | grep -q "^n8n-network$" || docker network create n8n-network

docker compose up -d
