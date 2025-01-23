variables {
  vnc_bind_address     = "0.0.0.0"
  vnc_port_max         = "5930"
  vnc_port_min         = "5920"
  accelerator          = "kvm"
  headless             = "true"
  qemu_disk_cache      = "unsafe"
  qemu_format          = "qcow2"
  boot_wait            = "15s"
  disk_compression     = "true"
  disk_discard         = "unmap"
  disk_size            = "4G"
  arc                  = "x86_64"
  disk_interface       = "virtio"
  format               = "qcow2"
  net_device           = "virtio-net"
  config_folder        = "config/"
  output_dir           = "output/"
  ssh_username         = "root"
  ssh_password         = "i5VA3RSwi8ExsQ"
  ssh_wait_timeout     = "15m"
  cpu                  = "4"
  ram                  = "2048"
  iso_checksum_type    = "sha512"
  debian-12_iso         = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.9.0-amd64-netinst.iso"
  debian-12_iso_checksum = "9ebe405c3404a005ce926e483bc6c6841b405c4d85e0c8a7b1707a7fe4957c617ae44bd807a57ec3e5c2d3e99f2101dfb26ef36b3720896906bdc3aaeec4cd80"
}

source "qemu" "debian-12-btrfs-x86_64" {
  output_directory = "${var.output_dir}/debian-12-btrfs-x86_64"
  disk_size        = "${var.disk_size}"
  boot_command     = [
    "<esc><wait>", "auto <wait>",
    "console-keymaps-at/keymap=de <wait>",
    "console-setup/ask_detect=false <wait>", "debconf/frontend=noninteractive <wait>",
    "fb=false <wait>", "kbd-chooser/method=us <wait>", "keyboard-configuration/xkb-keymap=us <wait>",
    "locale=en_US <wait>", "netcfg/get_hostname=debian <wait>",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.config_folder}debian/preseed-legacy-btrfs.cfg <wait>",
    "<enter><wait>"
  ]
  boot_wait        = var.boot_wait
  disk_cache       = var.qemu_disk_cache
  accelerator      = var.accelerator
  disk_compression = var.disk_compression
  disk_discard     = var.disk_discard
  disk_interface   = var.disk_interface
  format           = var.format
  headless         = var.headless
  http_directory   = "."
  iso_checksum     = var.debian-12_iso_checksum
  iso_urls         = [var.debian-12_iso]
  net_device       = var.net_device
  qemuargs         = [["-m", "${var.ram}M"], ["-smp", "${var.cpu}"]]
  shutdown_command = "echo '${var.ssh_password}' | shutdown -P now"
  ssh_password     = var.ssh_password
  ssh_username     = var.ssh_username
  ssh_wait_timeout = var.ssh_wait_timeout
  vnc_bind_address = var.vnc_bind_address
  vnc_port_min     = var.vnc_port_min
  vnc_port_max     = var.vnc_port_max
}

source "qemu" "debian-12-x86_64" {
  output_directory = "${var.output_dir}/debian-12-x86_64"
  disk_size        = "${var.disk_size}"
  boot_command     = [
    "<esc><wait>", "auto <wait>",
    "console-keymaps-at/keymap=de <wait>",
    "console-setup/ask_detect=false <wait>", "debconf/frontend=noninteractive <wait>",
    "fb=false <wait>", "kbd-chooser/method=us <wait>", "keyboard-configuration/xkb-keymap=us <wait>",
    "locale=en_US <wait>", "netcfg/get_hostname=debian <wait>",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.config_folder}debian/preseed-legacy.cfg <wait>",
    "<enter><wait>"
  ]
  boot_wait        = var.boot_wait
  disk_cache       = var.qemu_disk_cache
  accelerator      = var.accelerator
  disk_compression = var.disk_compression
  disk_discard     = var.disk_discard
  disk_interface   = var.disk_interface
  format           = var.format
  headless         = var.headless
  http_directory   = "."
  iso_checksum     = var.debian-12_iso_checksum
  iso_urls         = [var.debian-12_iso]
  net_device       = var.net_device
  qemuargs         = [["-m", "${var.ram}M"], ["-smp", "${var.cpu}"]]
  shutdown_command = "echo '${var.ssh_password}' | shutdown -P now"
  ssh_password     = var.ssh_password
  ssh_username     = var.ssh_username
  ssh_wait_timeout = var.ssh_wait_timeout
  vnc_bind_address = var.vnc_bind_address
  vnc_port_min     = var.vnc_port_min
  vnc_port_max     = var.vnc_port_max
}

build {
  sources = [
    "qemu.debian-12-x86_64"
  ]

  provisioner "shell" {
    valid_exit_codes = [0, 1, 127]
    script           = "config/linux/script.sh"
  }
}