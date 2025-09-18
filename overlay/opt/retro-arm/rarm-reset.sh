#!/bin/bash
RARM=$(pass show rarm/stuff) > /dev/null 2>&1
echo -e "${RARM}" | sudo -S true >/dev/null 2>&1
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
ROMS_DIR="/home/robot/RetroPie/roms"
echo -e "${RED}Starting RETRO-ARM reset process..."
echo "5 seconds to cancel (CTRL-C)..."
sleep 5
echo -e "${NC}"
find "$ROMS_DIR" -type f -print -exec rm -fv {} +
echo -e "${BLUE}ROMs have been removed.${NC}"
ARMBIAN_ENV="/boot/armbianEnv.txt"
sed -i '/^extraargs=/d' "$ARMBIAN_ENV"
echo -e "${BLUE}Removed boot resolution.${NC}"
RARM_DIR="/opt/retro-arm"
find "$RARM_DIR" -type f -name "*.check" -print -exec rm -fv {} +
echo -e "${BLUE}Removed .check files.${NC}"
echo
echo -e "${GREEN}RETRO-OPI reset process complete.${NC}"
echo -e "${RED}Rebooting system...${NC}"
sleep 1
sudo reboot
sleep 10
