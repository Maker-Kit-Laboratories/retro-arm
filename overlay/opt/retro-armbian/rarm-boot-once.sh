#!/bin/bash
hostnamectl set-hostname retro-armbian
echo "retro-armbian" >/etc/hostname
sed -i 's/^\(127\.0\.1\.1\s*\).*/\1retro-armbian/' /etc/hosts
chown -R robot:robot /opt/retro-armbian/
chmod 755 /opt/retro-armbian/
mkdir -p /home/robot
chmod 755 /home/robot
rsync -a /opt/retro-armbian/robot/ /home/robot/
chown -R robot:robot /home/robot
cat >>/etc/samba/smb.conf <<"EOF"
[roms]
    path = /home/robot/RetroPie/roms
    read only = No
    valid users = robot
EOF
GNUPGHOME="/home/robot/.gnupg"
mkdir -p ${GNUPGHOME}
chown -R robot:robot ${GNUPGHOME}
chmod 700 ${GNUPGHOME}
sudo -u robot -H gpg --batch --passphrase '' --quick-gen-key "robot <robot@localhost>" default default never
ROBOT_GPG=$(sudo -u robot -H gpg --list-secret-keys --with-colons | awk -F: '/^fpr:/ {print $10; exit}')
sudo -u robot -H pass init ${ROBOT_GPG}
echo "retroarm" | sudo -u robot -H pass insert -e -f rarm/stuff
(echo "retroarm"; echo "retroarm") | smbpasswd -s -a robot
systemctl enable avahi-daemon
sed -i '/^bootlogo=/d' "/boot/armbianEnv.txt" || true
echo "bootlogo=true" >> "/boot/armbianEnv.txt"
update-initramfs -u
rm -- "$0"