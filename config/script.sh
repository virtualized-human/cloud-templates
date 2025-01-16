#!/bin/bash
# ENV
export DEBIAN_FRONTEND=noninteractive
# Updates and Tools
apt-get -y update
apt-get -y full-upgrade
apt-get -y install htop iftop iotop nmon nload btop zip unzip tar bzip2 tmux nano vim wget curl screen sudo
# Cloud-Init/Guest Tools
apt-get -y install qemu-guest-agent cloud-init cloud-guest-utils
sed -i 's/disable_root: true/disable_root: false/' /etc/cloud/cloud.cfg
## Blank Password
passwd -d root
passwd -l root
# Fstab
sed -i 's|btrfs[[:space:]]\+defaults|btrfs   defaults,discard=async|' /etc/fstab
# SSH
echo -e '# Restrict key exchange, cipher, and MAC algorithms, as per sshaudit.com\n# hardening guide.\nKexAlgorithms sntrup761x25519-sha512@openssh.com,gss-curve25519-sha256-,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256,gss-group16-sha512-,diffie-hellman-group16-sha512\n\nCiphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-gcm@openssh.com,aes128-ctr\n\nMACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com\n\nHostKeyAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256\n\nCASignatureAlgorithms sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256\n\nGSSAPIKexAlgorithms gss-curve25519-sha256-,gss-group16-sha512-\n\nHostbasedAcceptedAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256\n\nPubkeyAcceptedAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256' >> /etc/ssh/sshd_config.d/ssh-audit_hardening.conf
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# Fail2Ban
apt-get -y install fail2ban python3-systemd
systemctl stop fail2ban
systemctl enable fail2ban
cat << "EOF" > /etc/fail2ban/jail.local
[DEFAULT]
backend = systemd

bantime = 5400
maxretry = 5
findtime = 600

[sshd]
enabled = true
EOF
# NTP
apt-get install -y ntp
apt-get purge -y systemd-timesyncd
systemctl stop ntp
echo "server ntp.virtualized.app iburst" > /etc/ntpsec/ntp.conf
systemctl enable ntp
# Network
## Resolvconf for DNS via ifupdown2, ifupdown2 as modern ifupdown replacement.
apt-get -y install resolvconf ifupdown2
apt-get -y purge ifupdown
echo -e '# This file describes the network interfaces available on your system\n# and how to activate them. For more information, see interfaces(5).\n\nsource /etc/network/interfaces.d/*' > /etc/network/interfaces
systemctl enable networking
mkdir -p /etc/systemd/system/networking.service.d
cat << "EOF" > /etc/systemd/system/networking.service.d/override.conf
[Unit]
After=network-pre.target
EOF
systemctl daemon-reload
# First-boot
apt-get -y install cron
systemctl stop cron
systemctl enable cron
cat << "EOF" > /etc/cron.d/first-boot-cmds
PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
LD_LIBRARY_PATH=/usr/local/lib
@reboot root sleep 10 && sed -i 's/^preserve_hostname: false/preserve_hostname: true/' /etc/cloud/cloud.cfg
@reboot root sleep 11 && sed -i 's/^ - update_etc_hosts/# - update_etc_hosts/' /etc/cloud/cloud.cfg
@reboot root sleep 12 && sed -i '1i ssh_deletekeys: false' /etc/cloud/cloud.cfg
@reboot root sleep 13 && sed -i 's/^ - package-update-upgrade-install/# - package-update-upgrade-install/' /etc/cloud/cloud.cfg
@reboot root sleep 14 && rm -f /etc/cron.d/first-boot-cmds
EOF
# Cleanup
apt-get -y autoremove --purge
apt-get clean
truncate -s 0 /etc/machine-id
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /etc/ssh/*host*key*
find /var/log -type f -exec truncate -s 0 {} \;
history -c
sync
