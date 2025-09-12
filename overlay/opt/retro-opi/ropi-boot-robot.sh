#!/bin/bash
echo "retroopi" | sudo -S systemctl stop smbd nmbd >/dev/null 2>&1
echo
GREEN='\033[38;5;70m'
ORANGE='\033[38;5;214m'
RED='\033[38;5;203m'
NC='\033[0m'
echo -e "${GREEN}  ______     ______     ______   ______     ______      ${ORANGE}     ______     ______   __    "
echo -e "${GREEN} /\  == \   /\  ___\   /\__  _\ /\  == \   /\  __ \     ${ORANGE}    /\  __ \   /\  == \ /\ \   "
echo -e "${GREEN} \ \  __<   \ \  __\   \/_/\ \/ \ \  __<   \ \ \/\ \    ${ORANGE}    \ \ \/\ \  \ \  _-/ \ \ \  "
echo -e "${GREEN}  \ \_\ \_\  \ \_____\    \ \_\  \ \_\ \_\  \ \_____\   ${ORANGE}     \ \_____\  \ \_\    \ \_\ "
echo -e "${GREEN}   \/_/ /_/   \/_____/     \/_/   \/_/ /_/   \/_____/   ${ORANGE}      \/_____/   \/_/     \/_/ "
echo -e "${NC}"
echo
echo -e "WELCOME TO ${GREEN}RETRO ${ORANGE}OPI ${RED}ARMBIAN${NC}"
echo "========================================"
sleep 2
echo
echo
if ip route | grep -q default; then
    echo -e "${GREEN}Network connection detected.${NC}"
    echo "retroopi" | sudo -S systemctl start smbd nmbd >/dev/null 2>&1
else
    echo -e "${RED}No active network connection detected.${NC}"
    sleep 2
    if [ ! -f /opt/retro-opi/ropi-connect.check ]; then
        ropi-connect
    fi
fi
echo
echo
if [ ! -f /opt/retro-opi/ropi-resolution.check ]; then
    ropi-resolution
fi
sudo -u robot -H ropi-play