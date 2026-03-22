#!/bin/bash
GREEN='\033[38;5;70m'
RED='\033[38;5;203m'
NC='\033[0m'
system_list=("nes" "snes" "mastersystem" "megadrive" "gba" "gbc")
system_shorthand_list=("nes" "snes" "sms" "md" "gba" "gbc")
download_roms_for_system() {
    local system="$1"
    local shorthand="$2"
    mkdir -p "/home/robot/RetroPie/roms/$system"
    cd "/home/robot/RetroPie/roms/$system"
    wget --no-check-certificate -q -O master.zip "https://codeload.github.com/retrobrews/${shorthand}-games/zip/master" 2>/dev/null || true
    if [ -f master.zip ]; then
        unzip -q master.zip 2>/dev/null || true
        mv -f "${shorthand}-games-master"/* /home/robot/RetroPie/roms/$system 2>/dev/null || true
        rm -f master.zip
    fi
    echo -e "${GREEN}ROMs installed for ${system}${NC}"
}
create_empty_folders() {
    for system in "${system_list[@]}"; do
        mkdir -p "/home/robot/RetroPie/roms/$system"
        echo -e "${GREEN}Empty folder created for ${system}${NC}"
    done
}
clear
echo -e "${GREEN}RETROBREW ROM INSTALLER:${NC}"
echo -e "${GREEN}=========================${NC}"
read -p "Select [y/N]: " install_roms
if [[ "$install_roms" =~ ^[Yy]$ ]]; then
    for i in "${!system_list[@]}"; do
        system="${system_list[$i]}"
        shorthand="${system_shorthand_list[$i]}"
        download_roms_for_system "$system" "$shorthand"
    done
else
    create_empty_folders
fi