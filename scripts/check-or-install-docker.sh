if command -v docker &> /dev/null; then
    echo -e " ${GREEN}> Docker jest zainstalowany${NORMAL}"
    return 0
else
    echo -e " ${RED}> Docker nie jest zainstalowany!${NORMAL}"
    
    echo -e " ${YELLOW}> Rozpoczynam instalację Docker...${NORMAL}"
    chmod +x ""

    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo usermod -aG docker $USER
    newgrp docker

    echo -e " ${GREEN}🐳 Docker zainstalowany! Teraz możesz konteneryzować nawet swoje problemy! 🎉${NORMAL}"
    return 0
fi
