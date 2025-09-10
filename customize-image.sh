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
# VIDEO CONFIGURATION (720P)
#################################################################
echo "extraargs=video=HDMI-A-1:1280x720@60" >> "/boot/armbianEnv.txt"


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
# ROBOT LOGIN SCRIPT
#################################################################
mkdir -p /opt/boot/
cat >/opt/boot/retro-opi-robot.sh <<EOF
#!/bin/bash
echo "retroopi" | sudo -S systemctl stop nmbd >/dev/null 2>&1tty
echo "retroopi" | sudo -S systemctl stop smbd >/dev/null 2>&1
echo
GREEN='\033[38;5;70m'
ORANGE='\033[0;33m'
RED='\033[38;5;203m'
NC='\033[0m'
echo -e "\${GREEN}  ______     ______     ______   ______     ______      \${ORANGE}     ______     ______   __    "
echo -e "\${GREEN} /\  == \   /\  ___\   /\__  _\ /\  == \   /\  __ \     \${ORANGE}    /\  __ \   /\  == \ /\ \   "
echo -e "\${GREEN} \ \  __<   \ \  __\   \/_/\ \/ \ \  __<   \ \ \/\ \    \${ORANGE}    \ \ \/\ \  \ \  _-/ \ \ \  "
echo -e "\${GREEN}  \ \_\ \_\  \ \_____\    \ \_\  \ \_\ \_\  \ \_____\   \${ORANGE}     \ \_____\  \ \_\    \ \_\ "
echo -e "\${GREEN}   \/_/ /_/   \/_____/     \/_/   \/_/ /_/   \/_____/   \${ORANGE}      \/_____/   \/_/     \/_/ "
echo -e "\${NC}"
echo
echo -e "WELCOME TO \${GREEN}RETRO \${ORANGE}OPI \${RED}ARMBIAN\${NC}"
echo "========================================"
echo
sleep 2
echo
echo
echo
if ip route | grep -q default; then
    echo -e "\${GREEN}Network connection detected.\${NC}"
    echo "retroopi" | sudo -S systemctl start smbd nmbd >/dev/null 2>&1
else
    echo -e "\${RED}No active network connection detected.\${NC}"
    sleep 2
    echo "retroopi" | sudo -S true >/dev/null 2>&1
    export TERM=linux
    sudo nmtui
    clear
    if ip route | grep -q default; then
        echo -e "\${GREEN}Network connection established.\${NC}"
        echo "retroopi" | sudo -S systemctl start smbd nmbd >/dev/null 2>&1
        sleep 2
    fi
    echo "retroopi" | sudo -S false >/dev/null 2>&1
fi
echo
echo
echo -e "\${ORANGE}Starting...\${NC}"
sleep 2
sudo -u robot -H XDG_RUNTIME_DIR="/run/user/1000" emulationstation

EOF
chmod +x /opt/boot/retro-opi-robot.sh


#################################################################
# ROBOT LOGIN SCRIPT AUTO START
#################################################################
cat >>/home/robot/.profile <<"EOF"
if [ $(tty) = "/dev/tty1" ]; then
    /opt/boot/retro-opi-robot.sh
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


#################################################################
# RETROARCH SETTINGS
#################################################################
echo 'audio_driver = "alsa"' >> /opt/retropie/configs/all/retroarch.cfg


#################################################################
# INSTALL ROMS
#################################################################
download_and_install_roms() {
    download_roms_for_system "nes" "nes"
    download_roms_for_system "snes" "snes"
    download_roms_for_system "mastersystem" "sms"
    download_roms_for_system "megadrive" "md"
    download_roms_for_system "gba" "gba"
    download_roms_for_system "gbc" "gbc"
}

download_roms_for_system() {
    local system="$1"
    local shorthand="$2"
    mkdir -p "/opt/roms/$system"
    cd "/opt/roms/$system"
    wget --no-check-certificate -q -O master.zip "https://codeload.github.com/retrobrews/${shorthand}-games/zip/master"
    unzip master.zip
    mkdir -p "/opt/boot/robot/RetroPie/roms/$system"
    mv -v "${shorthand}-games-master"/* "/opt/boot/robot/RetroPie/roms/$system"
    cd ..
    rm -rf "/opt/roms/$system"
}

download_and_install_roms

#################################################################
# STORE ROBOT
#################################################################
rsync -a /home/robot/ /opt/boot/robot/


#################################################################
# ROBOT AUTOLOGIN
#################################################################
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat >/etc/systemd/system/getty@tty1.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/sbin/agetty --autologin robot --noclear %I \$TERM
EOF


#################################################################
# BOOT SCRIPT
#################################################################
mkdir -p /opt/boot/
cat >/opt/boot/retro-opi-boot.sh <<EOF
#!/bin/bash
hostnamectl set-hostname retro-opi
echo "retro-opi" >/etc/hostname
sed -i 's/^\(127\.0\.1\.1\s*\).*/\1retro-opi/' /etc/hosts
mkdir -p /home/robot
chmod 755 /home/robot
rsync -a /opt/boot/robot/ /home/robot/
chown -R robot:robot /home/robot
cat >>/etc/samba/smb.conf <<EOL
[roms]
    path = /home/robot/RetroPie/roms
    read only = No
    valid users = robot
EOL
systemctl enable avahi-daemon
EOF

chmod +x /opt/boot/retro-opi-boot.sh


#################################################################
# BOOT SCRIPT SERVICE
#################################################################
cat >/etc/systemd/system/retro-opi-boot.service <<EOF
[Unit]
Description=Retro OPi - Initial Boot Script

[Service]
Type=oneshot
ExecStart=/opt/boot/retro-opi-boot.sh
ExecStartPost=/bin/systemctl disable retro-opi-boot.service
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF

ln -sf /etc/systemd/system/retro-opi-boot.service /etc/systemd/system/multi-user.target.wants/retro-opi-boot.service


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
