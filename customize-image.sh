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
# INSTALL DEPENDENCIES
#################################################################
apt-get install -y samba


#################################################################
# INSTALL RETROPIE
#################################################################
cd /opt
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
chmod +x retropie_setup.sh
./retropie_setup.sh

#DEBUG
echo ROBOT HOME:
ls -la /home/robot


#################################################################
# INSTALL ROMS
#################################################################
download_and_install_roms() {
    download_roms_for_system "nes" "nes"
    download_roms_for_system "snes" "snes"
    download_roms_for_system "mastersystem" "sms"
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
    rm -rf "${shorthand}-games-master"
    rm master.zip
}

download_and_install_roms

#################################################################
# STORE ROBOT
#################################################################
mkdir -p /opt/boot/robot
rsync -a /home/robot/ /opt/boot/robot/


#################################################################
# RETROPIE AUTO START
#################################################################
cat >/etc/systemd/system/retropie.service <<EOF
[Unit]
Description=Start Retro Pie - EmulationStation
After=getty@tty1.service

[Service]
Type=simple
User=robot
ExecStart=emulationstation
Restart=on-failure
RestartSec=10

[Install]
WantedBy=getty@tty1.service
EOF

ln -sf /etc/systemd/system/retropie.service /etc/systemd/system/multi-user.target.wants/retropie.service


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
cat >/etc/samba/smb.conf <<EOL
[global]
    workgroup = WORKGROUP
    server string = Retro OPi
    map to guest = Bad User
    dns proxy = no

[RETRO-OPI-ROMS]
    path = /home/robot/RetroPie/roms
    browseable = yes
    read only = no
    guest ok = yes
    force user = robot
EOL

systemctl enable smbd
systemctl restart smbd
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
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF

ln -sf /etc/systemd/system/retro-opi-boot.service /etc/systemd/system/multi-user.target.wants/retro-opi-boot.service


#################################################################
# ROBOT LOGIN SCRIPT
#################################################################
mkdir -p /opt/boot/
cat >/opt/boot/retro-opi-robot.sh <<EOF
#!/bin/bash
exec > /dev/tty1 2>&1
echo
GREEN='\033[38;5;70m'
ORANGE='\033[38;5;208m'
RED='\033[38;5;203m'
NC='\033[0m'
echo -e "\${GREEN}  ______     ______     ______   ______     ______      \${ORANGE}     ______     ______   __    "
echo -e "\${GREEN} /\  == \   /\  ___\   /\__  _\ /\  == \   /\  __ \     \${ORANGE}    /\  __ \   /\  == \ /\ \   "
echo -e "\${GREEN} \ \  __<   \ \  __\   \/_/\ \/ \ \  __<   \ \ \/\ \    \${ORANGE}    \ \ \/\ \  \ \  _-/ \ \ \  "
echo -e "\${GREEN}  \ \_\ \_\  \ \_____\    \ \_\  \ \_\ \_\  \ \_____\   \${ORANGE}     \ \_____\  \ \_\    \ \_\ "
echo -e "\${GREEN}   \/_/ /_/   \/_____/     \/_/   \/_/ /_/   \/_____/   \${ORANGE}      \/_____/   \/_/     \/_/ "
echo -e "\${NC}"
echo
echo -e "WELCOME TO \${GREEN}RETRO \${ORANGE}OPI \${RED}ARMBIAN"
echo "=============================================="
echo
sleep 20
export TERM=linux
nmtui
EOF
chmod +x /opt/boot/retro-opi-robot.sh


#################################################################
# ROBOT LOGIN SCRIPT SERVICE
#################################################################
cat >/etc/systemd/system/retro-opi-robot.service <<EOF
[Unit]
Description=Retro OPi - Robot Login Script
After=getty@tty1.service
Before=retropie.service

[Service]
Type=oneshot
User=robot
ExecStart=/opt/boot/retro-opi-robot.sh

[Install]
WantedBy=getty@tty1.service
EOF


ln -sf /etc/systemd/system/retro-opi-robot.service /etc/systemd/system/multi-user.target.wants/retro-opi-robot.service


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
