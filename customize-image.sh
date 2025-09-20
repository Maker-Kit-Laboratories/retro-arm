#!/bin/bash
set -e


#################################################################
# STORE PROCESSES
#################################################################
captured_pids=$(ls /proc | grep '^[0-9]\+$')


#################################################################
# USERS
#################################################################
echo "root:retroarm" | chpasswd
useradd -m -s /bin/bash robot
mkdir -p /home/robot
cp -a /etc/skel/. /home/robot/
echo "robot:retroarm" | chpasswd
echo "robot ALL=(ALL) ALL" >/etc/sudoers.d/robot
chmod 440 /etc/sudoers.d/robot
chown -R robot:robot /home/robot


#################################################################
# DEPENDENCIES
#################################################################
apt-get update
apt-get install -y samba avahi-daemon pass gpg edid-decode
systemctl disable smbd nmbd


#################################################################
# SYNC FILES
#################################################################
mkdir -p /opt/retro-arm/
rsync -av /tmp/overlay/ /
chown -R robot:robot /opt/retro-arm
chown -R robot:robot /home/robot
cp -f /opt/retro-arm/watermark.png /usr/share/plymouth/themes/armbian/watermark.png


#################################################################
# ROBOT BOOT SCRIPT
#################################################################
chmod +x /opt/retro-arm/rarm-boot-robot.sh
chown robot:robot /opt/retro-arm/rarm-boot-robot.sh


#################################################################
# ROBOT BOOT SCRIPT AUTOMATION
#################################################################
cat >>/home/robot/.profile <<"EOF"
if [ $(tty) = "/dev/tty1" ]; then
    /opt/retro-arm/rarm-boot-robot.sh
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
echo -e "RETROPIE SETUP COMPLETE"
echo -e "======================"


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
# RARM-RETROBREW COMMAND
#################################################################
chmod +x /opt/retro-arm/rarm-retrobrew.sh
chown robot:robot /opt/retro-arm/rarm-retrobrew.sh
ln -sf /opt/retro-arm/rarm-retrobrew.sh /usr/local/bin/rarm-retrobrew
rarm-retrobrew


#################################################################
# STORE ROBOT USER DATA
#################################################################
rsync -a /home/robot/ /opt/retro-arm/robot/


#################################################################
# ROBOT AUTOLOGIN
#################################################################
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat >/etc/systemd/system/getty@tty1.service.d/override.conf <<"EOF"
[Service]
ExecStart=
ExecStart=/sbin/agetty --autologin robot --noclear %I $TERM

[Unit]
After=rarm-boot-once.service
EOF


#################################################################
# INITIAL BOOT SCRIPT
#################################################################
chmod +x /opt/retro-arm/rarm-boot-once.sh
chown robot:robot /opt/retro-arm/rarm-boot-once.sh
cp -f /opt/retro-arm/rarm-boot-once.service /etc/systemd/system/rarm-boot-once.service
ln -sf /etc/systemd/system/rarm-boot-once.service /etc/systemd/system/multi-user.target.wants/rarm-boot-once.service


#################################################################
# RARM-RESOLUTION COMMAND
#################################################################
chmod +x /opt/retro-arm/rarm-resolution.sh
chown robot:robot /opt/retro-arm/rarm-resolution.sh
ln -sf /opt/retro-arm/rarm-resolution.sh /usr/local/bin/rarm-resolution


#################################################################
# RARM-CONNECT COMMAND
#################################################################
chmod +x /opt/retro-arm/rarm-connect.sh
chown robot:robot /opt/retro-arm/rarm-connect.sh
ln -sf /opt/retro-arm/rarm-connect.sh /usr/local/bin/rarm-connect


#################################################################
# RARM-PLAY COMMAND
#################################################################
chmod +x /opt/retro-arm/rarm-play.sh
chown robot:robot /opt/retro-arm/rarm-play.sh
ln -sf /opt/retro-arm/rarm-play.sh /usr/local/bin/rarm-play


#################################################################
# RARM-RESET COMMAND
#################################################################
chmod +x /opt/retro-arm/rarm-reset.sh
chown robot:robot /opt/retro-arm/rarm-reset.sh
ln -sf /opt/retro-arm/rarm-reset.sh /usr/local/bin/rarm-reset


#################################################################
# RARM-PASSWORD COMMAND
#################################################################
chmod +x /opt/retro-arm/rarm-password.sh
chown robot:robot /opt/retro-arm/rarm-password.sh
ln -sf /opt/retro-arm/rarm-password.sh /usr/local/bin/rarm-password


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