#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NORMAL='\033[0m'

MIN_RAM_MB=${1:-1024}

# Sprawdzenie czy parametr to liczba
if ! [[ "$MIN_RAM_MB" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Błąd: Parametr musi być liczbą (MB)${NORMAL}"
    echo "Usage: $0 [MIN_MB]"
    echo "Przykład: $0 2048    # sprawdź czy jest 2048MB RAM"
    return  1
fi

# Sprawdzenie RAM
CURRENT_RAM=$(free -m | awk '/^Mem:/ {print $2}')

if [ $CURRENT_RAM -gt $MIN_RAM_MB ]; then
    echo -e "${GREEN}System ma ${CURRENT_RAM}MB RAM (wymagane: ${MIN_RAM_MB}MB)${NORMAL}"
    return  0
else
    echo -e "${RED}System ma ${CURRENT_RAM}MB RAM - za mało! (wymagane: ${MIN_RAM_MB}MB)${NORMAL}"
    return  2
fi