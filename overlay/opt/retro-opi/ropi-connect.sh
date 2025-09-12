#!/bin/bash
sleep 1
echo "retroopi" | sudo -S true >/dev/null 2>&1
export TERM=linux
sudo nmtui
clear
if ip route | grep -q default; then
    echo "retroopi" | sudo -S systemctl start smbd nmbd >/dev/null 2>&1
    echo -e "${GREEN}Network connection detected. File share enabled.${NC}"
    sleep 2
fi
echo "retroopi" | sudo -S false >/dev/null 2>&1
touch /opt/retro-opi/ropi-connect.check