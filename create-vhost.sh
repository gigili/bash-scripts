#!/bin/bash

# 			GNU GENERAL PUBLIC LICENSE
#			  Version 3, 29 June 2007
#
# Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.

#title           :create-vhost
#description     :This script will create a new virtual host file and add entries to the /etc/hosts file
#author		     :Igor Ilić
#website	     :https://igorilic.net
#twitter	     :https://twitter.com/Gac_BL
#date            :22-06-2020
#version         :0.1
#usage		     :create-vhost.sh <project-url> <project-path>

slugify() {
	slug=$(echo "$1" | iconv -t ascii//TRANSLIT | sed -r s/[~^]+//g | sed -r s/[^a-zA-Z0-9]+/_/g | sed -r s/^-+\|-+\$//g | tr "[:upper:]" "[:lower:]")
	echo "$slug"
}

#clear

VHOST_URL="$1"            # Virtual host url
PROJECT_PATH="${2:-$PWD}" # Use current dir for the path
SERVER_ADMIN_EMAIL="admin@example.com"

log() {
	color=""
	prefix="[INFO]"
	lvl=${2:-"info"}

	if [[ "$lvl" == "success" ]]; then
		color="\e[92m"
		prefix="[SUCCESS]"
	elif [[ "$lvl" == "warning" ]]; then
		color="\e[93m"
		prefix="[WARNING]"
	elif [[ "$lvl" == "error" ]]; then
		color="\e[91m"
		prefix="[ERROR]"
	else
		color="\e[37m"
	fi

	if [ "$USE_SILENT" = true ] && [ "$lvl" != "error" ]; then
		return
	fi

	echo -e "$color$prefix $1 \e[0m"
}

ask_for_confirmation() {

	if [ "$USE_SILENT" = true ]; then
		true
		return
	fi

	echo -n -e "\e[37mConfirm [Y/n]:\e[0m "
	read -n 1 -r
	echo

	if [[ -z "$REPLY" ]]; then
		REPLY="y"
	fi

	case "$REPLY" in
	y | Y) true return ;;
	n | N) false return ;;
	*) ask_for_confirmation ;;
	esac

}

abort() {
	log "Aborting ..." "error"
	exit 0
}

setup_virtual_host() {
	VIRTUAL_HOST_PATH="/etc/httpd/conf/extra/sites-enabled/"

	log "New virtual host config:" "info"
	log "Url: $VHOST_URL" "info"
	log "Project path: $PROJECT_PATH" "info"
	log "Setup new virtual host?" "info"

	if ! ask_for_confirmation; then
		log "Skipping virtual host creation" "info"
		return
	fi

	if [[ ! -d "$PROJECT_PATH" ]]; then
		log "Project path doesn't exists... Creating" "warning"
		mkdir -p "$PROJECT_PATH"
		chmod -R 775 "$PROJECT_PATH/"
	fi

	if [[ ! -d "$PROJECT_PATH/logs" ]]; then
		log "Logs folder inside of project path doesn't exist... Creating" "warning"
		mkdir -p "$PROJECT_PATH/logs"
		chmod -R 775 "$PROJECT_PATH/logs/"
	fi

	log "Creating new virtual host entry for $VHOST_URL" "info"

	SL_VHOST_URL="$(slugify $VHOST_URL)"

	VH_FILE="<VirtualHost *:80>
		ServerAdmin $SERVER_ADMIN_EMAIL
		DocumentRoot \"$PROJECT_PATH\"
		ServerName $VHOST_URL
		ServerAlias www.$VHOST_URL
		ErrorLog \"$PROJECT_PATH/logs/error.log\"
		CustomLog \"$PROJECT_PATH/logs/access.log\" common
		<Directory \"$PROJECT_PATH\">
			AllowOverride All
		</Directory>
	</VirtualHost>"

	if [[ ! -d "$VIRTUAL_HOST_PATH" ]]; then
		log "Invalid path to the virtual hosts config folder." "error"
		return
	fi

	if [[ $(echo "$VH_FILE" | sudo tee "$VIRTUAL_HOST_PATH/$SL_VHOST_URL.conf") ]]; then
		log "Virtual host for $PROJECT_NAME created successfully" "success"

		if [[ $(printf "\n127.0.0.1 %s" $VHOST_URL | sudo tee -a "/etc/hosts") ]] &&
			[[ $(printf "\n127.0.0.1 www.%s" $VHOST_URL | sudo tee -a "/etc/hosts") ]]; then
			log "Added $VHOST_URL to the hosts file" "success"
		fi

		log "Restarting apache" "info"

		if [[ -z $(sudo systemctl restart httpd) ]]; then
			log "Apache service restarted" "success"
		else
			log "Unable to restart apache" "warning"
		fi
	fi
}

if [[ -z "$PROJECT_PATH" ]]; then
	PROJECT_PATH="$PWD/$SL_PROJECT_NAME"
fi

if [[ -z "$VHOST_URL" ]]; then
	log "Virtual host url can't be empty" "error"
	abort
fi

setup_virtual_host
