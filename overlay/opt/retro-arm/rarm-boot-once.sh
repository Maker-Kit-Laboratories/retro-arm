#!/bin/bash
hostnamectl set-hostname retro-arm
echo "retro-arm" >/etc/hostname
sed -i 's/^\(127\.0\.1\.1\s*\).*/\1retro-arm/' /etc/hosts
chown -R robot:robot /opt/retro-arm/
chmod 755 /opt/retro-arm/
mkdir -p /home/robot
chmod 755 /home/robot
rsync -a /opt/retro-arm/robot/ /home/robot/
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