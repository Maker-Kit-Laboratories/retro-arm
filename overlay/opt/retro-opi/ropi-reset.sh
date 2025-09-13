#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
ROMS_DIR="/home/robot/RetroPie/roms"
echo -e "${RED}Starting ROM reset process..."
echo "5 seconds to cancel (CTRL-C)..."
sleep 5
echo -e "${NC}"
if [ -d "$ROMS_DIR" ]; then
    find "$ROMS_DIR" -type f -print -exec rm -fv {} +
    echo -e "${GREEN}ROMs have been removed.${NC}"
else
    echo -e "${RED}ROMs directory not found: $ROMS_DIR${NC}"
fi