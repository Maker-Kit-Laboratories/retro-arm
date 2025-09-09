#!/bin/bash
#################################################################
# RETRO-OPI ARMBIAN IMAGE CREATOR
# MAKER KIT LABORATORIES // 2025 // https://makerkitlab.xyz
# VERSION 0.07
# NOTES:
# - Armbian, Retro Pie and all included open source games are under their respective licenses.
# - This script automates the process of creating a Retro-OPI Armbian image with open source games pre-installed.
# - Tested on:
#   - Orange Pi Zero 3
#   - Orange Pi Zero 2w
#
#################################################################
set -e


#################################################################
# CLONE ARMBIAN
#################################################################
if [ ! -d build ]; then
    git clone --branch v25.08 --depth=1 https://github.com/armbian/build.git
fi

clear

#################################################################
# HEADER
#################################################################
echo
GREEN='\033[38;5;70m'
ORANGE='\033[38;5;208m'
RED='\033[38;5;203m'
NC='\033[0m'
echo -e "${GREEN}  ______     ______     ______   ______     ______      ${ORANGE}     ______     ______   __    "
echo -e "${GREEN} /\  == \   /\  ___\   /\__  _\ /\  == \   /\  __ \     ${ORANGE}    /\  __ \   /\  == \ /\ \   "
echo -e "${GREEN} \ \  __<   \ \  __\   \/_/\ \/ \ \  __<   \ \ \/\ \    ${ORANGE}    \ \ \/\ \  \ \  _-/ \ \ \  "
echo -e "${GREEN}  \ \_\ \_\  \ \_____\    \ \_\  \ \_\ \_\  \ \_____\   ${ORANGE}     \ \_____\  \ \_\    \ \_\ "
echo -e "${GREEN}   \/_/ /_/   \/_____/     \/_/   \/_/ /_/   \/_____/   ${ORANGE}      \/_____/   \/_/     \/_/ "
echo -e "${NC}"
echo
echo -e "MAKER KIT LABORATORIES - ${GREEN}RETRO ${ORANGE}OPI ${RED}ARMBIAN ${NC}IMAGE CREATOR"
echo "========================================================="
sleep 3
echo
echo -e "${RED}ARMBIAN ${NC}SBC Support List"
echo "=========================="
echo

#################################################################
# BOARD SELECTION
#################################################################

boards=()
i=1
for file in build/config/boards/orangepi*.csc; do
    [ -e "$file" ] || continue
    board=$(basename "$file" .csc)
    echo "$i) $board"
    boards+=("$board")
    ((i++))
done
echo
read -p "Select a board by number: " selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#boards[@]}" ]; then
    echo -e "${RED}Invalid selection."
    exit 1
fi
BOARD="${boards[$((selection-1))]}"
echo -e "${NC}Selected board: ${ORANGE}$BOARD"
echo -e "${NC}"


#################################################################
# EDIT CONFIG FILE (WIP)
#################################################################


#################################################################
# COPY CONFIG FILES
#################################################################
mkdir -p build/userpatches
cp customize-image.sh build/userpatches/
sudo chmod +x build/userpatches/customize-image.sh


#################################################################
# BUILD
#################################################################
cd build
DISTRO="ubuntu"
RELEASE="noble"
ARCH="arm64"
./compile.sh BOARD="${BOARD}" DISTRO="${DISTRO}" RELEASE="${RELEASE}" ARCH="${ARCH}" INSTALL_HEADERS="yes"
cd ../

#################################################################
# COMPRESS IMAGE
#################################################################
IMAGE_FILE=$(ls -t build/output/images/*.img | head -n 1)
sudo xz -T0 -z -v -9 -k -f "$IMAGE_FILE"

#################################################################
# FINISHED
#################################################################
echo ""
echo ""
echo "IMAGE BUILT AND COMPRESSED SUCCESSFULLY"
echo "========================================"
echo "${IMAGE_FILE}.xz"
