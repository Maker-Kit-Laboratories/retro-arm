#!/bin/bash
RARM=$(pass show rarm/stuff) > /dev/null 2>&1
BLUE='\033[38;5;45m'
RED='\033[38;5;203m'
NC='\033[0m'

echo "$RARM" | sudo -S true >/dev/null 2>&1

for device in /sys/class/drm/*HDMI*; do
    if [ -d "$device" ] && [ "$(cat "$device/status")" = "connected" ]; then
        OUT="$device"
        echo 1 | sudo tee "$OUT/status" >/dev/null 2>&1
        break
    fi
done

if [ -z "$OUT" ]; then
    echo "No HDMI output detected."
    exit 1
fi

DECODED_EDID=$(edid-decode < "$OUT/edid" 2>&1)

declare -A resolution_refresh_rates

while IFS= read -r line; do
    if [[ $line =~ ([0-9]{3,4}x[0-9]{3,4}[i]?).*([0-9]{2}\.[0-9]+\ Hz) ]]; then
        res="${BASH_REMATCH[1]}"
        refresh="${BASH_REMATCH[2]}"
        
        res_clean="${res%i}"
        
        if [[ -n "${resolution_refresh_rates[$res_clean]}" ]]; then
            resolution_refresh_rates[$res_clean]="${resolution_refresh_rates[$res_clean]}, $refresh"
        else
            resolution_refresh_rates[$res_clean]="$refresh"
        fi
    fi
done <<< "$DECODED_EDID"

resolutions=()
for res in $(printf '%s\n' "${!resolution_refresh_rates[@]}" | sort -V); do
    resolutions+=("$res")
done

echo -e "${BLUE}\033[1mSelect HDMI Resolution (720P Recommended):\033[0m${NC}"
for i in "${!resolutions[@]}"; do
    echo "$((i+1)). ${resolutions[i]}"
done
echo ""

read -p "Select a resolution: " choice
selected_resolution="${resolutions[$((choice-1))]}"

echo ""
echo -e "${BLUE}\033[1mAvailable refresh rates for ${selected_resolution}:\033[0m${NC}"

refresh_list="${resolution_refresh_rates[$selected_resolution]}"
IFS=',' read -ra refresh_array <<< "$refresh_list"

unique_refresh_rates=()
declare -A seen_rates

for rate in "${refresh_array[@]}"; do
    rate=$(echo "$rate" | sed 's/^ *//')
    if [[ -z "${seen_rates[$rate]}" ]]; then
        seen_rates[$rate]=1
        unique_refresh_rates+=("$rate")
    fi
done

IFS=$'\n' unique_refresh_rates=($(sort -rn <<<"${unique_refresh_rates[*]}"))

for i in "${!unique_refresh_rates[@]}"; do
    echo "$((i+1)). ${unique_refresh_rates[i]}"
done
echo ""

read -p "Select a refresh rate: " refresh_choice
selected_refresh="${unique_refresh_rates[$((refresh_choice-1))]}"

refresh_rate=$(echo "$selected_refresh" | sed 's/ Hz//' | sed 's/\..*//')

sudo sed -i '/^disp_mode=/d' /boot/armbianEnv.txt
echo "disp_mode=${selected_resolution}p${refresh_rate}" | sudo tee -a /boot/armbianEnv.txt >/dev/null
sudo sed -i '/^extraargs=/d' /boot/armbianEnv.txt
name=$(basename "$OUT")
out_name=$(echo "$name" | sed -E 's/^[^-]+-//')
echo "extraargs=video=${out_name}:${selected_resolution}@${refresh_rate}" | sudo tee -a /boot/armbianEnv.txt >/dev/null

echo -e "${BLUE}Resolution: ${NC}${selected_resolution} at ${refresh_rate}Hz."
echo -e "${RED}Rebooting system now (CTRL-C to cancel).${NC}"
touch /opt/retro-arm/rarm-resolution.check

for i in {5..0}; do
    echo -e "${RED}$i"
    sleep 1
done

sudo reboot