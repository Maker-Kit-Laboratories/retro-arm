#!/bin/bash
ROPI=$(pass show ropi/stuff) > /dev/null 2>&1
echo "$ROPI" | sudo -S systemctl stop smbd nmbd >/dev/null 2>&1
GREEN='\033[38;5;70m'
ORANGE='\033[38;5;214m'
RED='\033[38;5;203m'
NC='\033[0m'
echo -e "${GREEN}  ______     ______     ______   ______     ______          ______     ______   __    "
echo -e "${GREEN} /\  == \   /\  ___\   /\__  _\ /\  == \   /\  __ \        /\  __ \   /\  == \ /\ \   "
echo -e "${GREEN} \ \  __<   \ \  __\   \/_/\ \/ \ \  __<   \ \ \/\ \       \ \ \/\ \  \ \  _-/ \ \ \  "
echo -e "${GREEN}  \ \_\ \_\  \ \_____\    \ \_\  \ \_\ \_\  \ \_____\       \ \_____\  \ \_\    \ \_\ "
echo -e "${GREEN}   \/_/ /_/   \/_____/     \/_/   \/_/ /_/   \/_____/        \/_____/   \/_/     \/_/ "
echo -e "${NC}"  
echo
echo -e "WELCOME TO ${GREEN}RETRO OPI ${RED}ARMBIAN${NC}"
echo "========================================"
sleep 2
echo
echo
if [ ! -f /opt/retro-opi/ropi-password.check ]; then
    ropi-password
fi
if ip route | grep -q default; then
    echo -e "${GREEN}Network connection detected.${NC}"
    echo "$ROPI" | sudo -S systemctl start smbd nmbd >/dev/null 2>&1
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
ropi-play