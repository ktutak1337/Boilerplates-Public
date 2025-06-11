#!/bin/bash

scripts=(
    "check-disk-space.sh"
    "check-or-install-docker.sh"
    "check-ram.sh"
    "fetch-docker-configs.sh"
    "install-docker-engine-on-ubuntu.sh"
)

mkdir -p $HOME/scripts


curl -fsSL "https://raw.githubusercontent.com/ktutak1337/Boilerplates-Public/refs/heads/main/scripts/fetch-docker-configs.sh" -o "${HOME}/scripts/fetch-docker-configs.sh"
chmod +x $HOME/scripts/fetch-docker-configs.sh
cp $HOME/scripts/fetch-docker-configs.sh /usr/bin/fetch-docker-configs

source /usr/bin/fetch-docker-configs

setup_github_config "ktutak1337" "Boilerplates-Public" "main"
download_app_config "scripts" "scripts" "$HOME/scripts" "${scripts[@]}"

chmod +x "$HOME/scripts/"*.sh

for f in "$HOME/scripts/"*.sh; do
	sudo cp "$f" "/usr/bin/$(basename "${f%.sh}")"
done

# rm -rf /scripts

source check-ram 1024 || exit 1

source check-disk-space 1 || exit 1

source check-or-install-docker

mkdir -p $HOME/n8n/{db,data}

source setup-env

n8n_files=(
    "docker-compose.yml"
    ".env.example"
    "init-data.sh"
)

source /usr/bin/fetch-docker-configs

setup_github_config "ktutak1337" "Boilerplates-Public" "main"
download_app_config "docker" n8n" "$HOME/docker/n8n" "${n8n_files[@]}"
