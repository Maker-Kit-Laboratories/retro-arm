#!/bin/bash
ROPI=$(pass show ropi/stuff) > /dev/null 2>&1
sleep 1
echo "$ROPI" | sudo -S true >/dev/null 2>&1
export TERM=linux
sudo nmtui
clear -x
if ip route | grep -q default; then
    echo "$ROPI" | sudo -S systemctl start smbd nmbd >/dev/null 2>&1
    echo -e "${GREEN}Network connection detected. File share enabled.${NC}"
    sleep 2
fi
echo "$ROPI" | sudo -S false >/dev/null 2>&1
touch /opt/retro-opi/ropi-connect.check