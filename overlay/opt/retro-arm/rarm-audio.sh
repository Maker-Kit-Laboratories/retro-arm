#!/bin/bash
RARM=$(pass show rarm/stuff) > /dev/null 2>&1
BLUE='\033[38;5;45m'
GREEN='\033[38;5;70m'
RED='\033[38;5;203m'
NC='\033[0m'
BOLD='\033[1m'
echo "$RARM" | sudo -S true >/dev/null 2>&1
echo -e "${BLUE}${BOLD}Configuring HDMI Audio...${NC}"
hdmi_card=$(aplay -l | awk -F':' '/[Hh][Dd][Mm][Ii]/ {print $1}' | awk '{print $2}' | head -n1)
if [ -z "$hdmi_card" ]; then
    echo -e "${RED}HDMI audio device not found. Audio issues may occur.${NC}"
    exit 1
fi
cat > ~/.asoundrc <<EOF
pcm.!default {
    type plug
    slave.pcm "plughw:$hdmi_card"
}
ctl.!default {
    type hw
    card $hdmi_card
}
EOF
touch /opt/retro-arm/rarm-audio.check
echo -e "${GREEN}HDMI Audio configured successfully.${NC}"
exit 0
