#!/bin/bash
#################################################################
# RETRO-OPI ARMBIAN IMAGE CREATOR
# MAKER KIT LABORATORIES // 2025 // https://makerkitlab.xyz
# NOTES:
# - This script automates the process of creating a RETRO-OPI Armbian image with open source games optionally pre-installed.
#
#################################################################
set -e
sudo -S true


#################################################################
# ARGUMENTS
#################################################################
for arg in "$@"; do
    case $arg in
        BOARD=*)
            BOARD="${arg#BOARD=}"
            ;;
    esac
done


#################################################################
# INIT
#################################################################
sudo -v
( while true; do sudo -n true; sleep 60; done ) 2>/dev/null &


#################################################################
# DEFAULTS
#################################################################
NAME="retro-opi"
ARMBIAN_VERSION="25.08"
VERSION="0.2.0"
DISTRO="ubuntu"
RELEASE="noble"
ARCH="arm64"
GREEN='\033[38;5;70m'
ORANGE='\033[38;5;214m'
RED='\033[38;5;203m'
NC='\033[0m'


#################################################################
# CLONE ARMBIAN
#################################################################
if [ ! -d build ]; then
    git clone --branch v25.08 --depth=1 https://github.com/armbian/build.git
fi
clear -x


#################################################################
# HEADER
#################################################################
echo
echo -e "${ORANGE}  ______     ______     ______   ______     ______          ______     ______   __    "
echo -e "${ORANGE} /\  == \   /\  ___\   /\__  _\ /\  == \   /\  __ \        /\  __ \   /\  == \ /\ \   "
echo -e "${ORANGE} \ \  __<   \ \  __\   \/_/\ \/ \ \  __<   \ \ \/\ \       \ \ \/\ \  \ \  _-/ \ \ \  "
echo -e "${ORANGE}  \ \_\ \_\  \ \_____\    \ \_\  \ \_\ \_\  \ \_____\       \ \_____\  \ \_\    \ \_\ "
echo -e "${ORANGE}   \/_/ /_/   \/_____/     \/_/   \/_/ /_/   \/_____/        \/_____/   \/_/     \/_/ "
echo -e "${NC}"
echo
echo -e "MAKER KIT LABORATORIES - ${ORANGE}RETRO OPI ${RED}ARMBIAN ${NC}IMAGE CREATOR"
echo "========================================================="
echo -e "${ORANGE}RETRO OPI: ${NC}${VERSION}"
echo -e "${RED}ARMBIAN:   ${NC}${ARMBIAN_VERSION}"
sleep 1
echo



#################################################################
# BOARD SELECTION
#################################################################
if [ -z "$BOARD" ]; then
    echo -e "${NC}SBC List (support not confirmed):"
    echo "========================================================="
    echo
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
    read -p "Board: " selection
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#boards[@]}" ]; then
        echo -e "${RED}Invalid selection."
        exit 1
    fi
    BOARD="${boards[$((selection-1))]}"
    echo -e "${NC}Board: ${ORANGE}$BOARD"
    echo -e "${NC}"
else
    echo -e "${NC}Board: ${ORANGE}$BOARD"
    echo -e "${NC}"
fi


#################################################################
# COPY CONFIG FILES
#################################################################
mkdir -p build/userpatches
cp customize-image.sh build/userpatches/
sudo chmod +x build/userpatches/customize-image.sh
rm -rf build/userpatches/overlay
rsync -av overlay/ build/userpatches/overlay/



#################################################################
# BUILD
#################################################################
if ! build/compile.sh BOARD="${BOARD}" DISTRO="${DISTRO}" RELEASE="${RELEASE}" ARCH="${ARCH}" INSTALL_HEADERS="yes"; then
    echo -e "${RED}IMAGE BUILD FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}IMAGE BUILT SUCCESSFULLY${NC}"
    echo -e "${GREEN}=========================${NC}"
fi


#################################################################
# COMPRESS IMAGE
#################################################################
IMAGE_FILE=$(ls -t build/output/images/*.img | head -n 1)
COMPRESSED_IMAGE_FILE="${NAME}-${VERSION}-armbian-${ARMBIAN_VERSION}-${BOARD}.img.xz"
if ! sudo xz -T0 -z -v -9 -k -f "$IMAGE_FILE"; then
    echo -e "${RED}IMAGE COMPRESSION FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}IMAGE COMPRESSED SUCCESSFULLY${NC}"
    echo -e "${GREEN}==============================${NC}"
    mkdir -p output
    mv -f "${IMAGE_FILE}.xz" "output/${COMPRESSED_IMAGE_FILE}"
    echo -e "${ORANGE}${COMPRESSED_IMAGE_FILE}${NC}"
    exit 0
fi
