#!/bin/bash
GREEN='\033[0;32m'
NC='\033[0m'
RARM=$(pass show rarm/stuff) > /dev/null 2>&1
sleep 1
echo "$RARM" | sudo -S true >/dev/null 2>&1
export TERM=linux
sudo nmtui
clear -x
if ip route | grep -q default; then
    echo "$RARM" | sudo -S systemctl start smbd nmbd >/dev/null 2>&1
    echo -e "${GREEN}Network connection detected. File share enabled.${NC}"
    sleep 2
fi
echo "$RARM" | sudo -S false >/dev/null 2>&1
touch /opt/retro-armbian/rarm-connect.check