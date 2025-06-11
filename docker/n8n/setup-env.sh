#!/bin/bash
set -euo pipefail

update_env_var() {
	VAR_NAME="$1"
	DISPLAY_NAME="$2"
	DEFAULT_VALUE="$3"      # "" jeśli brak domyślnej
	IS_SECRET="$4"          # "true" lub "false"

	while true; do
		if [[ "$IS_SECRET" == "true" ]]; then
			read -s -p "Podaj ${DISPLAY_NAME}${DEFAULT_VALUE:+ (domyślnie: $DEFAULT_VALUE)}: " VALUE < /dev/tty
			echo
		else
			read -p "Podaj ${DISPLAY_NAME}${DEFAULT_VALUE:+ (domyślnie: $DEFAULT_VALUE)}: " VALUE < /dev/tty
		fi

		if [[ -z "$VALUE" && -n "$DEFAULT_VALUE" ]]; then
			VALUE="$DEFAULT_VALUE"
		fi

		if [[ -z "$VALUE" ]]; then
			echo "❌ Wartość nie może być pusta. Spróbuj ponownie."
		else
			break
		fi
	done

	ESCAPED_VALUE=$(printf '%s\n' "$VALUE" | sed 's/[\/&]/\\&/g')

	if grep -q "^${VAR_NAME}=" .env; then
		sed -i "s/^${VAR_NAME}=.*/${VAR_NAME}=${ESCAPED_VALUE}/" .env
	else
		echo "${VAR_NAME}=${VALUE}" >> .env
	fi

	unset VALUE
	unset ESCAPED_VALUE
}

update_env_var "SUB_DOMAIN" "subdomenę" "n8n" "false"
update_env_var "DOMAIN" "domenę" "example.com" "false"


update_env_var "POSTGRES_PASSWORD" "hasło PostgreSQL (root)" "" "true"
update_env_var "POSTGRES_NON_ROOT_PASSWORD" "hasło PostgreSQL (non-root: n8n)" "" "true"
update_env_var "REDIS_PASSWORD" "hasło Redis" "" "true"
update_env_var "N8N_BASIC_AUTH_PASSWORD" "hasło n8n Basic Auth" "" "true"

echo "N8N_PATH=$HOME/docker/n8n/data" >> .env
echo "DB_PATH=$HOME/docker/n8n/db" >> .env
echo "DB_SETUP_PATH=$HOME/docker/n8n/init-data.sh" >> .env

DOMAIN=$(grep '^DOMAIN=' .env | cut -d '=' -f2- | tr -d '\\"')
SUB_DOMAIN=$(grep '^SUB_DOMAIN=' .env | cut -d '=' -f2- | tr -d '\\"')

if [[ "$DOMAIN" == "example.com" ]]; then
	sed -i "s/^N8N_HOST=.*/N8N_HOST=localhost/" .env || echo "N8N_HOST=localhost" >> .env
else
	sed -i "s/^N8N_HOST=.*/N8N_HOST=${DOMAIN}/" .env || echo "N8N_HOST=${DOMAIN}" >> .env
fi

sed -i "s|^WEBHOOK_URL=.*|WEBHOOK_URL=https://${SUB_DOMAIN}.${DOMAIN}/|" .env