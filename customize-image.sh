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
apt-get install -y samba avahi-daemon pass gpg
systemctl disable smbd nmbd


#################################################################
# SYNC FILES
#################################################################
mkdir -p /opt/retro-opi/
rsync -av /tmp/overlay/ /
chown -R robot:robot /opt/retro-opi
chown -R robot:robot /home/robot
cp -f /opt/retro-opi/watermark.png /usr/share/plymouth/themes/armbian/watermark.png


#################################################################
# ROBOT BOOT SCRIPT
#################################################################
chmod +x /opt/retro-opi/ropi-boot-robot.sh
chown robot:robot /opt/retro-opi/ropi-boot-robot.sh


#################################################################
# ROBOT BOOT SCRIPT AUTOMATION
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
clear -x
echo -e "${GREEN}RETROPIE SETUP COMPLETE${NC}"


#################################################################
# RETRO PIE SETTINGS
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
# ROPI-RETROBREW COMMAND
#################################################################
chmod +x /opt/retro-opi/ropi-retrobrew.sh
chown robot:robot /opt/retro-opi/ropi-retrobrew.sh
ln -sf /opt/retro-opi/ropi-retrobrew.sh /usr/local/bin/ropi-retrobrew
ropi-retrobrew


#################################################################
# STORE ROBOT USER DATA
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
# INITIAL BOOT SCRIPT
#################################################################
chmod +x /opt/retro-opi/ropi-boot-once.sh
chown robot:robot /opt/retro-opi/ropi-boot-once.sh
cp -f /opt/retro-opi/ropi-boot-once.service /etc/systemd/system/ropi-boot-once.service
ln -sf /etc/systemd/system/ropi-boot-once.service /etc/systemd/system/multi-user.target.wants/ropi-boot-once.service


#################################################################
# ROPI-RESOLUTION COMMAND
#################################################################
chmod +x /opt/retro-opi/ropi-resolution.sh
chown robot:robot /opt/retro-opi/ropi-resolution.sh
ln -sf /opt/retro-opi/ropi-resolution.sh /usr/local/bin/ropi-resolution


#################################################################
# ROPI-CONNECT COMMAND
#################################################################
chmod +x /opt/retro-opi/ropi-connect.sh
chown robot:robot /opt/retro-opi/ropi-connect.sh
ln -sf /opt/retro-opi/ropi-connect.sh /usr/local/bin/ropi-connect


#################################################################
# ROPI-PLAY COMMAND
#################################################################
chmod +x /opt/retro-opi/ropi-play.sh
chown robot:robot /opt/retro-opi/ropi-play.sh
ln -sf /opt/retro-opi/ropi-play.sh /usr/local/bin/ropi-play


#################################################################
# ROPI-RESET COMMAND
#################################################################
chmod +x /opt/retro-opi/ropi-reset.sh
chown robot:robot /opt/retro-opi/ropi-reset.sh
ln -sf /opt/retro-opi/ropi-reset.sh /usr/local/bin/ropi-reset


#################################################################
# ROPI-PASSWORD COMMAND
#################################################################
chmod +x /opt/retro-opi/ropi-password.sh
chown robot:robot /opt/retro-opi/ropi-password.sh
ln -sf /opt/retro-opi/ropi-password.sh /usr/local/bin/ropi-password


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