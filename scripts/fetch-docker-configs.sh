 #!/bin/bash

download_file() {
    local filename="$1"
    local target_path="$2"
    local make_executable="${3:-false}"
    
    echo -e " ${BLUE}> Pobieram ${filename}...${NORMAL}"
    
    if curl -fsSL "${BASE_URL}/${filename}" -o "${target_path}"; then
        if [ "$make_executable" = true ]; then
            chmod +x "$target_path"
            echo -e " ${GREEN}✓ ${filename} pobrany i executable${NORMAL}"
        else
            echo -e " ${GREEN}✓ ${filename} pobrany${NORMAL}"
        fi
        return 0
    else
        echo -e " ${RED}✗ Błąd pobierania ${filename}${NORMAL}"
        return 1
    fi
}

download_app_config() {
    local resource_type="$1"      # "docker" lub "scripts"
    local app_name="$2"           # np. "n8n", "portainer", "scripts"
    local target_dir="$3"         # np. "$HOME/docker/n8n", "$HOME/scripts"
    local files_array=("${@:4}")  # array plików do pobrania
    
    echo -e " ${YELLOW}> Pobieram ${resource_type}/${app_name}...${NORMAL}"
    
    # Buduj BASE_URL w zależności od typu zasobu
    local app_base_url="${GITHUB_BASE_URL}/${resource_type}/${app_name}"
    
    # Pobierz wszystkie pliki z array
    for file in "${files_array[@]}"; do
        local target_path="${target_dir}/${file}"
        
        # Sprawdź czy plik ma być executable (pliki .sh)
        if [[ "$file" == *.sh ]]; then
            download_file "$file" "$target_path" true || return 1
        else
            download_file "$file" "$target_path" || return 1
        fi
    done
    
    # Auto-tworzenie .env z .env.example (tylko dla docker)
    if [[ "$resource_type" == "docker" ]] && [[ " ${files_array[*]} " =~ " .env.example " ]]; then
        if [ ! -f "${target_dir}/.env" ]; then
            echo -e " ${YELLOW}> Tworzę plik .env z template...${NORMAL}"
            cp "${target_dir}/.env.example" "${target_dir}/.env"
            echo -e " ${GREEN}✓ Plik .env utworzony${NORMAL}"
        else
            echo -e " ${GREEN}> Plik .env już istnieje - pomijam${NORMAL}"
        fi
    fi
    
    # Różne komunikaty końcowe w zależności od typu
    if [[ "$resource_type" == "docker" ]]; then
        echo -e " ${GREEN}🎉 ${app_name} gotowe do uruchomienia!${NORMAL}"
        echo -e " ${BLUE}📁 Pliki w: ${target_dir}${NORMAL}"
        echo -e " ${BLUE}🚀 Uruchom: cd ${target_dir} && docker compose up -d${NORMAL}"
    elif [[ "$resource_type" == "scripts" ]]; then
        echo -e " ${GREEN}🎉 Skrypty ${app_name} pobrane pomyślnie!${NORMAL}"
        echo -e " ${BLUE}📁 Skrypty w: ${target_dir}${NORMAL}"
    fi
}

# Funkcja helper do ustawiania GitHub URL
setup_github_config() {
    local github_user="$1"
    local github_repo="$2"
    local github_branch="${3:-main}"
    
    export GITHUB_BASE_URL="https://raw.githubusercontent.com/${github_user}/${github_repo}/refs/heads/${github_branch}"
}