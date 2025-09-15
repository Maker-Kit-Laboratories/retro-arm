#!/bin/bash
GREEN='\033[38;5;70m'
RED='\033[38;5;203m'
NC='\033[0m'
download_roms_for_system() {
    local system="$1"
    local shorthand="$2"
    mkdir -p "/opt/roms/$system"
    cd "/opt/roms/$system"
    wget --no-check-certificate -q -O master.zip "https://codeload.github.com/retrobrews/${shorthand}-games/zip/master"
    unzip master.zip
    mv -f -v "${shorthand}-games-master"/* "/home/robot/RetroPie/roms/$system"
    cd ..
    rm -rf "/opt/roms/$system"
}
download_and_install_roms() {
    download_roms_for_system "nes" "nes"
    download_roms_for_system "snes" "snes"
    download_roms_for_system "mastersystem" "sms"
    download_roms_for_system "megadrive" "md"
    download_roms_for_system "gba" "gba"
    download_roms_for_system "gbc" "gbc"
}
clear -x
echo
echo -e "${GREEN}RETROBREW ROM INSTALLER:${NC}"
echo -e "${GREEN}=========================${NC}"
echo -e "Select [y/N]:"
read -p "" roms
if [[ ! "$roms" =~ ^[Yy]$ ]]; then
    echo -e "${RED}ROMs Skipped.${NC}"
else
    download_and_install_roms
fi