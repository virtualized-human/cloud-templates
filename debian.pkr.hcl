variables {
  vm_name              = "packer"
  vnc_bind_address     = "0.0.0.0"
  vnc_port_max         = "5920"
  vnc_port_min         = "5920"
  accelerator          = "kvm"
  headless             = "true"
  output_dir           = "./output"
  qemu_disk_cache      = "unsafe"
  qemu_format          = "qcow2"
  boot_wait            = "15s"
  disk_compression     = "true"
  disk_discard         = "unmap"
  arc                  = "x86_64"
  disk_interface       = "virtio"
  format               = "qcow2"
  net_device           = "virtio-net"
  config_folder        = "config/"
  ssh_username         = "root"
  ssh_password         = "i5VA3RSwi8ExsQ"
  ssh_wait_timeout     = "15m"
  cpu                  = "4"
  ram                  = "2048"
  iso_checksum_type    = "sha512"
  iso_12               = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.9.0-amd64-netinst.iso"
  iso_12_checksum      = "9ebe405c3404a005ce926e483bc6c6841b405c4d85e0c8a7b1707a7fe4957c617ae44bd807a57ec3e5c2d3e99f2101dfb26ef36b3720896906bdc3aaeec4cd80"
}

source "qemu" "legacy-12-x86_64" {
  vm_name          = var.vm_name
  output_directory = "${var.output_dir}/debian/legacy-12-x86_64"
  disk_size        = "4G"
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
  iso_checksum     = var.iso_12_checksum
  iso_urls         = [var.iso_12]
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
    "qemu.legacy-12-x86_64"
  ]

  provisioner "shell" {
    valid_exit_codes = [0, 1, 127]
    script           = "config/debian/script.sh"
  }
}