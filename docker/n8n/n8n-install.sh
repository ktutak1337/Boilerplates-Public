 #!/bin/bash

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

setup_github_config "ktutak1337" "Boilerplates-Public" "main"
download_app_config "n8n" "$HOME/docker/n8n" "${n8n_files[@]}"
