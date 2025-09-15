#!/bin/bash
RARM=$(pass show rarm/stuff) > /dev/null 2>&1
BLUE='\033[38;5;45m'
RED='\033[38;5;203m'
NC='\033[0m'
for device in /sys/class/drm/*HDMI*; do
    if [ -d "$device" ] && [ "$(cat "$device/status")" = "connected" ]; then
        OUT="$device"
        break
    fi
done
if [ -z "$OUT" ]; then
    echo "No HDMI output detected."
    exit 1
fi
echo -e "${BLUE}\033[1mSelect HDMI Resolution (720P Recommended):\033[0m${NC}"
mapfile -t MODES < <(grep -v 'i' "$OUT/modes" | sort -rV | awk '!seen[$0]++')
PS3=" "
select mode in "${MODES[@]}"; do
    [ -n "$mode" ] || { echo -e "${RED}Invalid${NC}"; res="1280x720"; continue; }
    res=${mode}
    echo "$RARM" | sudo -S true >/dev/null 2>&1
    sudo sed -i '/^disp_mode=/d' /boot/armbianEnv.txt
    echo "disp_mode=${res}" | sudo tee -a /boot/armbianEnv.txt >/dev/null
    sudo sed -i '/^extraargs=/d' /boot/armbianEnv.txt
    name=$(basename "$OUT")
    out_name=$(echo "$name" | sed -E 's/^[^-]+-//')
    echo "extraargs=video=${out_name}:${res}" | sudo tee -a /boot/armbianEnv.txt >/dev/null
    echo -e "${BLUE}Resolution: ${NC}${res}."
    echo -e "${RED}Rebooting system now (CTRL-C to cancel).${NC}"
    touch /opt/retro-armbian/ropi-resolution.check
    sleep 1
    echo -e "${RED}5"
    sleep 1
    echo -e "${RED}4"
    sleep 1
    echo -e "${RED}3"
    sleep 1
    echo -e "${RED}2"
    sleep 1
    echo -e "${RED}1"
    sleep 1
    echo -e "${RED}0"
    sudo reboot
    sleep 10
    break
done