# cloud-templates

This packer repo builds customized cloud images according to the style of @virtualized_human for use in virtualization environments such as proxmox and co.

## Special features and differences to classic cloud images:

1. Use of “ifupdown2” for network instead of Netplan
    - This fixes a problem in combination with Proxmox where onlink routes are not possible. For example, you cannot use “/32” CIDR.
    - ifupdown2 has the ability to recognize incremental changes and reload configurations. Furthermore, it is fully compatible with debians ifupdown - but can do much more.
    - in combination with resolvconf, which is also used, the `/etc/resolv.conf` is always maintained correctly and via `/etc/network/interfaces` and there is no unnecessary intermediate resolver, as with cloud-images which often rely on systemd-resolved.

2. Optimized configuration of NTP
    - systemd-timesyncd is used and as NTP server `ntp.virtualized.app`, public ntp servers are entered as fallback.
    - systemd-timesyncd is set so that it ensures that the time is correct every 60 seconds at the latest - very useful if you roll back the snapshots from a VPS to adjust the time (SSL Cert errors and co.)

3. Optimized configuration of Cloud-Init
    - at least under proxmox it is typical that a cloud-init repeatedly regenerates the `/etc/hosts`, the hostname and the ssh keys. This is very frustrating if you have only made small changes (such as the user password or the network).  This is completely taken into account here and it is ensured that this does not happen.

3. Important packages pre-installed
    - I have pre-installed packages that I consider important and use again and again.


## Pre-built download (regularly updated)

available [here](https://pubcloud.virtualized.app/s/yD3j9xZDM2CFB5e)!

[Debian 12 64-Bit](https://pubcloud.virtualized.app/s/xJtMLGMjzpWKcFF/download/debian-12-x86_64.qcow2)
