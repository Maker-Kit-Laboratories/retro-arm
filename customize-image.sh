#!/bin/bash
set -e


#################################################################
# STORE PROCESSES
#################################################################
captured_pids=$(ls /proc | grep '^[0-9]\+$')


#################################################################
# USERS
#################################################################
echo "root:retroopi" | chpasswd
useradd -m -s /bin/bash robot
mkdir -p /home/robot
cp -a /etc/skel/. /home/robot/
echo "robot:retroopi" | chpasswd
echo "robot ALL=(ALL) ALL" >/etc/sudoers.d/robot
chmod 440 /etc/sudoers.d/robot
chown -R robot:robot /home/robot


#################################################################
# DEPENDENCIES
#################################################################
apt-get update
apt-get install -y samba avahi-daemon
echo -e "retroopi\nretroopi" | smbpasswd -a -s robot
systemctl disable smbd nmbd
systemctl daemon-reload


#################################################################
# RETRO-OPI DIRECTORY
#################################################################
mkdir -p /opt/retro-opi/
chown robot:robot /opt/retro-opi


#################################################################
# VIDEO CONFIGURATION
#################################################################
cat >/opt/retro-opi/ropi-set-resolution.sh <<"EOF"
#!/bin/bash
echo "retroopi" | sudo -S true >/dev/null 2>&1
BLUE='\033[38;5;45m'
RED='\033[38;5;203m'
NC='\033[0m'
echo -e "${BLUE}Select HDMI Resolution:${NC}"
echo -e "0) 1920x1080 (16:9)"
echo -e "1) 1280x720 (16:9)"
echo -e "2) 1024x768 (4:3)"
echo -e "3) 1024x600 (16:9)"
echo -e "4) 800x600 (4:3)"
echo -e "5) 800x400 (2:1)"
echo -e "6) 720x400 (16:9)"
echo -e "7) 640x480 (4:3)"
echo -e "8) 640x320 (2:1)"
echo -e "9) 320x240 (4:3)"
echo
read -p "Enter choice [0-9]: " choice
case "$choice" in
    0) res="1920x1080@60" ;;
    1) res="1280x720@60" ;;
    2) res="1024x768@60" ;;
    3) res="1024x600@60" ;;
    4) res="800x600@60" ;;
    5) res="800x400@60" ;;
    6) res="720x400@60" ;;
    7) res="640x480@60" ;;
    8) res="640x320@60" ;;
    9) res="320x240@60" ;;
    *) echo "${RED}Invalid choice. ${NC}Defaulting to 1280x720@60."; res="1280x720@60" ;;
esac
echo "extraargs=video=HDMI-A-1:$res" >> "/boot/armbianEnv.txt"
echo -e "${BLUE}Resolution: ${NC}$res."
echo -e "${RED}Rebooting system now.${NC}"
touch /opt/retro-opi/ropi-resolution-set.check
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
EOF
chmod +x /opt/retro-opi/ropi-set-resolution.sh
chown robot:robot /opt/retro-opi/ropi-set-resolution.sh
ln -sf /opt/retro-opi/ropi-set-resolution.sh /usr/local/bin/ropi-set-resolution


#################################################################
# AUDIO CONFIGURATION
#################################################################
cat >/home/robot/.asoundrc <<EOF
pcm.!default {
    type plug
    slave.pcm "plughw:1"
}
ctl.!default {
    type hw
    card 1
}
EOF
chown robot:robot /home/robot/.asoundrc
chmod 644 /home/robot/.asoundrc


#################################################################
# NETWORK CONFIGURATION
#################################################################
cat >/opt/retro-opi/ropi-connect-network.sh <<"EOF"
#!/bin/bash
echo "Checking network..."
sleep 1
echo "retroopi" | sudo -S true >/dev/null 2>&1
export TERM=linux
sudo nmtui
clear
if ip route | grep -q default; then
    echo "retroopi" | sudo -S systemctl start smbd nmbd >/dev/null 2>&1
    echo -e "${GREEN}Network connection detected. File share enabled.${NC}"
    sleep 2
fi
echo "retroopi" | sudo -S false >/dev/null 2>&1
touch /opt/retro-opi/ropi-network-set.check
EOF
chmod +x /opt/retro-opi/ropi-connect-network.sh
chown robot:robot /opt/retro-opi/ropi-connect-network.sh
ln -sf /opt/retro-opi/ropi-connect-network.sh /usr/local/bin/ropi-connect-network


#################################################################
# ROBOT LOGIN SCRIPT
#################################################################
cat >/opt/retro-opi/ropi-boot-robot.sh <<"EOF"
#!/bin/bash
echo "retroopi" | sudo -S systemctl stop smbd nmbd >/dev/null 2>&1
echo
GREEN='\033[38;5;70m'
ORANGE='\033[38;5;214m'
RED='\033[38;5;203m'
NC='\033[0m'
echo -e "${GREEN}  ______     ______     ______   ______     ______      ${ORANGE}     ______     ______   __    "
echo -e "${GREEN} /\  == \   /\  ___\   /\__  _\ /\  == \   /\  __ \     ${ORANGE}    /\  __ \   /\  == \ /\ \   "
echo -e "${GREEN} \ \  __<   \ \  __\   \/_/\ \/ \ \  __<   \ \ \/\ \    ${ORANGE}    \ \ \/\ \  \ \  _-/ \ \ \  "
echo -e "${GREEN}  \ \_\ \_\  \ \_____\    \ \_\  \ \_\ \_\  \ \_____\   ${ORANGE}     \ \_____\  \ \_\    \ \_\ "
echo -e "${GREEN}   \/_/ /_/   \/_____/     \/_/   \/_/ /_/   \/_____/   ${ORANGE}      \/_____/   \/_/     \/_/ "
echo -e "${NC}"
echo
echo -e "WELCOME TO ${GREEN}RETRO ${ORANGE}OPI ${RED}ARMBIAN${NC}"
echo "========================================"
sleep 2
echo
echo
if ip route | grep -q default; then
    echo -e "${GREEN}Network connection detected.${NC}"
    echo "retroopi" | sudo -S systemctl start smbd nmbd >/dev/null 2>&1
else
    echo -e "${RED}No active network connection detected.${NC}"
    sleep 2
    if [ ! -f /opt/retro-opi/ropi-network-set.check ]; then
        ropi-connect-network
    fi
fi
echo
echo
if [ ! -f /opt/retro-opi/ropi-resolution-set.check ]; then
    ropi-set-resolution
fi
echo -e "${ORANGE}Starting...${NC}"
sleep 2
sudo -u robot -H XDG_RUNTIME_DIR="/run/user/1000" emulationstation
EOF
chmod +x /opt/retro-opi/ropi-boot-robot.sh
chown robot:robot /opt/retro-opi/ropi-boot-robot.sh


#################################################################
# ROBOT LOGIN SCRIPT AUTO START
#################################################################
cat >>/home/robot/.profile <<"EOF"
if [ $(tty) = "/dev/tty1" ]; then
    /opt/retro-opi/ropi-boot-robot.sh
fi
EOF


#################################################################
# INSTALL RETROPIE
#################################################################
cd /opt
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
chmod +x retropie_setup.sh
./retropie_setup.sh
clear
echo
echo
echo -e "${GREEN}RETROPIE INSTALLED${NC}"
#################################################################
# RETRO PIE SETTINGS
# TODO:
# - Add custom commands directly to emulationstation
#################################################################


#################################################################
# RETROARCH SETTINGS
#################################################################
set_retroarch_config() {
    local key="$1"
    local value="$2"
    local config_file="/opt/retropie/configs/all/retroarch.cfg"
    if grep -Eq "^\s*#?\s*${key}\s*=" "$config_file"; then
        sed -i "s|^\s*#\?\s*${key}\s*=.*|${key} = \"${value}\"|" "$config_file"
    else
        echo "${key} = \"${value}\"" >> "$config_file"
    fi
}
set_retroarch_config "audio_driver" "alsa"


#################################################################
# INSTALL ROMS
#################################################################
download_roms_for_system() {
    local system="$1"
    local shorthand="$2"
    mkdir -p "/opt/roms/$system"
    cd "/opt/roms/$system"
    wget --no-check-certificate -q -O master.zip "https://codeload.github.com/retrobrews/${shorthand}-games/zip/master"
    unzip master.zip
    mkdir -p "/opt/retro-opi/robot/RetroPie/roms/$system"
    mv -v "${shorthand}-games-master"/* "/opt/retro-opi/robot/RetroPie/roms/$system"
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
clear
echo -e "=========================================================================="
echo
echo -n "Download and install open-source ROMs? [y/N]: "
read download_roms
if [[ "$download_roms" =~ ^[Yy]$ ]]; then
    download_and_install_roms
fi


#################################################################
# STORE ROBOT
#################################################################
rsync -a /home/robot/ /opt/retro-opi/robot/


#################################################################
# ROBOT AUTOLOGIN
#################################################################
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat >/etc/systemd/system/getty@tty1.service.d/override.conf <<"EOF"
[Service]
ExecStart=
ExecStart=/sbin/agetty --autologin robot --noclear %I $TERM
EOF


#################################################################
# BOOT SCRIPT
#################################################################
cat >/opt/retro-opi/ropi-boot-once.sh <<"EOF"
#!/bin/bash
hostnamectl set-hostname retro-opi
echo "retro-opi" >/etc/hostname
sed -i 's/^\(127\.0\.1\.1\s*\).*/\1retro-opi/' /etc/hosts
chown -R robot:robot /opt/retro-opi/
chmod 755 /opt/retro-opi/
mkdir -p /home/robot
chmod 755 /home/robot
rsync -a /opt/retro-opi/robot/ /home/robot/
chown -R robot:robot /home/robot
cat >>/etc/samba/smb.conf <<EOL
[roms]
    path = /home/robot/RetroPie/roms
    read only = No
    valid users = robot
EOL
systemctl enable avahi-daemon
EOF

chmod +x /opt/retro-opi/ropi-boot-once.sh
chown robot:robot /opt/retro-opi/ropi-boot-once.sh


#################################################################
# BOOT SCRIPT SERVICE
#################################################################
cat >/etc/systemd/system/ropi-boot-once.service <<"EOF"
[Unit]
Description=Retro OPi - Initial Boot Script

[Service]
Type=oneshot
ExecStart=/opt/retro-opi/ropi-boot-once.sh
ExecStartPost=/bin/systemctl disable ropi-boot-once.service
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF

ln -sf /etc/systemd/system/ropi-boot-once.service /etc/systemd/system/multi-user.target.wants/ropi-boot-once.service


#################################################################
# KILL PROCESSES
#################################################################
current_pids=$(ls /proc | grep '^[0-9]\+$')
for pid in $current_pids; do
    if ! grep -q "^$pid$" <<< "$captured_pids"; then
        if [ "$pid" != "1" ]; then
            kill -9 "$pid" 2>/dev/null || true
        fi
    fi
done
exit 0