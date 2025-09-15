#!/bin/bash
RARM=$(pass show rarm/stuff) > /dev/null 2>&1
echo "$RARM" | sudo -S systemctl stop smbd nmbd >/dev/null 2>&1
GREEN='\033[38;5;70m'
ORANGE='\033[38;5;214m'
RED='\033[38;5;203m'
NC='\033[0m'
echo -e "${GREEN}  ______    ______    ______   ______    ______    " 
echo -e "${GREEN} /\  == \  /\  ___\  /\__  _\ /\  == \  /\  __ \   " 
echo -e "${GREEN} \ \  __<  \ \  __\  \/_/\ \/ \ \  __<  \ \ \/\ \  " 
echo -e "${GREEN}  \ \_\ \_\ \ \_____\   \ \_\  \ \_\ \_\ \ \_____\ " 
echo -e "${GREEN}   \/_/ /_/  \/_____/    \/_/   \/_/ /_/  \/_____/ " 
echo -e "${RED}" '  ______    ______    __    __    ______    __    ______    __   __     '
echo -e "${RED}" ' /\  __ \  /\  == \  /\ "-./  \  /\  == \  /\ \  /\  __ \  /\ "-.\ \    '
echo -e "${RED}" ' \ \  __ \ \ \  __<  \ \ \-./\ \ \ \  __<  \ \ \ \ \  __ \ \ \ \-.  \   '
echo -e "${RED}" '  \ \_\ \_\ \ \_\ \_\ \ \_\ \ \_\ \ \_____\ \ \_\ \ \_\ \_\ \ \_\\ "\_\ '
echo -e "${RED}" '   \/_/\/_/  \/_/ /_/  \/_/  \/_/  \/_____/  \/_/  \/_/\/_/  \/_/ \/_/  '
echo -e "${NC}"
echo
echo -e "WELCOME TO ${GREEN}RETRO ${RED}ARMBIAN${NC}"
echo "========================================"
sleep 2
echo
echo
if [ ! -f /opt/retro-armbian/rarm-password.check ]; then
    rarm-password
fi
if ip route | grep -q default; then
    echo -e "${GREEN}Network connection detected.${NC}"
    echo "$RARM" | sudo -S systemctl start smbd nmbd >/dev/null 2>&1
else
    echo -e "${RED}No active network connection detected.${NC}"
    sleep 2
    if [ ! -f /opt/retro-armbian/rarm-connect.check ]; then
        rarm-connect
    fi
fi
echo
echo
if [ ! -f /opt/retro-armbian/rarm-resolution.check ]; then
    rarm-resolution
fi
rarm-play