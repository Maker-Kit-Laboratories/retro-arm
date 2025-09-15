#!/bin/bash
#################################################################
# RETRO-ARMBIAN IMAGE CREATOR
# MAKER KIT LABORATORIES // 2025 // https://makerkitlab.xyz
# NOTES:
# - This script automates the process of creating a RETRO-ARMBIAN image with open source games optionally pre-installed.
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
NAME="retro-armbian"
ARMBIAN_VERSION="25.08"
VERSION="0.2.1"
DISTRO="ubuntu"
RELEASE="noble"
ARCH="arm64"
GREEN='\033[38;5;70m'
BLUE='\033[38;5;39m'
RED='\033[38;5;203m'
NC='\033[0m'


#################################################################
# HEADER
#################################################################
echo -e "${GREEN}  ______    ______    ______   ______    ______    " ${RED} '  ______    ______    __    __    ______    __    ______    __   __     '
echo -e "${GREEN} /\  == \  /\  ___\  /\__  _\ /\  == \  /\  __ \   " ${RED} ' /\  __ \  /\  == \  /\ "-./  \  /\  == \  /\ \  /\  __ \  /\ "-.\ \    '
echo -e "${GREEN} \ \  __<  \ \  __\  \/_/\ \/ \ \  __<  \ \ \/\ \  " ${RED} ' \ \  __ \ \ \  __<  \ \ \-./\ \ \ \  __<  \ \ \ \ \  __ \ \ \ \-.  \   '
echo -e "${GREEN}  \ \_\ \_\ \ \_____\   \ \_\  \ \_\ \_\ \ \_____\ " ${RED} '  \ \_\ \_\ \ \_\ \_\ \ \_\ \ \_\ \ \_____\ \ \_\ \ \_\ \_\ \ \_\\ "\_\ ' 
echo -e "${GREEN}   \/_/ /_/  \/_____/    \/_/   \/_/ /_/  \/_____/ " ${RED} '   \/_/\/_/  \/_/ /_/  \/_/  \/_/  \/_____/  \/_/  \/_/\/_/  \/_/ \/_/  '
echo
echo -e "${BLUE}MAKER KIT LABORATORIES${NC} - ${GREEN}RETRO${NC} ${RED}ARMBIAN${NC} - IMAGE CREATOR"
echo -e "${NC}========================================================="
echo -e "${GREEN}RETRO ${RED}ARMBIAN: ${NC}${VERSION}"
echo -e "${RED}ARMBIAN:       ${NC}${ARMBIAN_VERSION}"
sleep 1
echo


#################################################################
# CLONE ARMBIAN SUB-MODULE
#################################################################
if [ ! -d "armbian" ]; then
    echo -e "${BLUE}Initializing Armbian submodule...${NC}"
    git submodule update --init --recursive
else
    echo -e "${BLUE}Updating Armbian submodule...${NC}"
    git submodule update --remote --recursive armbian
fi
echo -e "${GREEN}Armbian submodule ready.${NC}"
sleep 1


#################################################################
# BOARD SELECTION
#################################################################
echo
if [ -z "$BOARD" ]; then
    echo -e "${BLUE}SBC List (support not confirmed):"
    echo -e "=========================================================${NC}"
    echo
    sleep 2
    boards=()
    i=1
    for file in armbian/config/boards/*.csc; do
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
mkdir -p armbian/userpatches
cp customize-image.sh armbian/userpatches/
sudo chmod +x armbian/userpatches/customize-image.sh
rm -rf armbian/userpatches/overlay
rsync -av overlay/ armbian/userpatches/overlay/



#################################################################
# BUILD
#################################################################
if ! armbian/compile.sh BOARD="${BOARD}" DISTRO="${DISTRO}" RELEASE="${RELEASE}" ARCH="${ARCH}" INSTALL_HEADERS="yes"; then
    echo
    echo -e "${RED}IMAGE BUILD FAILED${NC}"
    exit 1
else
    echo
    echo -e "${GREEN}IMAGE BUILT SUCCESSFULLY${NC}"
    echo -e "${GREEN}=========================${NC}"
fi


#################################################################
# COMPRESS IMAGE
#################################################################
echo
echo "COMPRESSING IMAGE..."
IMAGE_FILE=$(ls -t armbian/output/images/*.img | head -n 1)
COMPRESSED_IMAGE_FILE="${NAME}-${VERSION}-${ARMBIAN_VERSION}-${BOARD}.img.xz"
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
