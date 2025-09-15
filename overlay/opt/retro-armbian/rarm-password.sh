#!/bin/bash
RARM=$(pass show rarm/stuff) > /dev/null 2>&1
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
if [ -f /opt/retro-armbian/rarm-password.check ]; then
    rm -f /opt/retro-armbian/rarm-password.check
fi
change_password() {
    local user="$1"
    local password="$2"
    echo "$user:$password" | sudo chpasswd
}
echo "$RARM" | sudo -S true >/dev/null 2>&1
echo -e "${GREEN}Password Update:${NC}"
echo -e "${GREEN}================${NC}"
while true; do
    echo
    read -s -p "Enter new password: " pass1
    read -s -p "Confirm new password: " pass2
    echo
    if [ "$pass1" = "$pass2" ]; then
        change_password "robot" "$pass1"
        change_password "root" "$pass1"
        ROBOT_GPG=$(sudo -u robot -H gpg --list-secret-keys --with-colons | awk -F: '/^fpr:/ {print $10; exit}') >/dev/null 2>&1
        sudo -u robot -H pass init "$ROBOT_GPG" >/dev/null 2>&1
        echo "$pass1" | sudo -u robot -H pass insert -e -f rarm/stuff >/dev/null 2>&1
        (echo "$pass1"; echo "$pass1") | smbpasswd -s >/dev/null 2>&1
        touch /opt/retro-armbian/rarm-password.check
        clear
        echo -e "${GREEN}Password updated.${NC}"
        sleep 1
        break
    else
        echo -e "${RED}Passwords do not match. Please try again.${NC}"
    fi
done
