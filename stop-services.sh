#!/bin/bash

# 			GNU GENERAL PUBLIC LICENSE
#			  Version 3, 29 June 2007
#
# Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.

#title           :stop-service
#description     :This script will stop all services listed in the services array
#author		     :Igor Ilić
#website	     :https://igorilic.net
#twitter	     :https://twitter.com/Gac_BL
#date            :22-06-2020
#version         :0.1
#usage		     :stop-services.sh

services=("mssql-server" "minetest-server" "transmission-daemon")

for service in "${services[@]}"; do
	sudo service "$service" stop
	echo "Service $service status: $(service mssql-server status | awk '/Active: (.+)/ {print $2}')"
done
