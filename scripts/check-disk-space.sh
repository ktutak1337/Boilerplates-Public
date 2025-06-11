#!/bin/bash

# check-disk.sh - Sprawdzanie przestrzeni na dysku
# Usage: check-disk.sh [MIN_GB] [PATH]
# Default: 1GB w bieżącym katalogu

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NORMAL='\033[0m'

# Parametry - domyślnie 1GB w bieżącym katalogu
MIN_DISK_GB=${1:-1}
CHECK_PATH=${2:-.}

# Sprawdzenie czy parametr to liczba
if ! [[ "$MIN_DISK_GB" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Błąd: Pierwszy parametr musi być liczbą (GB)${NORMAL}"
    echo "Usage: $0 [MIN_GB] [PATH]"
    echo "Przykład: $0 5 /home    # sprawdź czy jest 5GB w /home"
    return  1
fi

# Sprawdzenie czy ścieżka istnieje
if [ ! -d "$CHECK_PATH" ]; then
    echo -e "${RED}Błąd: Ścieżka nie istnieje: $CHECK_PATH${NORMAL}"
    return  1
fi

# Sprawdzenie miejsca na dysku (dostępne GB)
AVAILABLE_GB=$(df -BG "$CHECK_PATH" | tail -1 | awk '{print $4}' | sed 's/G//')

if [ $AVAILABLE_GB -gt $MIN_DISK_GB ]; then
    echo -e "${GREEN}Dostępne ${AVAILABLE_GB}GB w $CHECK_PATH (wymagane: ${MIN_DISK_GB}GB)${NORMAL}"
    return  0
else
    echo -e "${RED}Dostępne ${AVAILABLE_GB}GB w $CHECK_PATH - za mało! (wymagane: ${MIN_DISK_GB}GB)${NORMAL}"
    return  2
fi

