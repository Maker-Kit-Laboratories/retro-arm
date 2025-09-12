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
cat >>/etc/samba/smb.conf <<"EOF"
[roms]
    path = /home/robot/RetroPie/roms
    read only = No
    valid users = robot
EOF
systemctl enable avahi-daemon
sed -i '/^bootlogo=/d' "/boot/armbianEnv.txt" || true
echo "bootlogo=true" >> "/boot/armbianEnv.txt"
update-initramfs -u
echo -e "${GREEN}RETRO-OPI BOOT ONCE COMPLETE${NC}"