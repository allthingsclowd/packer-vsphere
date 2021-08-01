variable "envoy_version" {
  // set using environment variable PKR_VAR_envoy_version
  type =  string
}

variable "webpagecounter_version" {
  // set using environment variable PKR_VAR_webpagecounter_version
  type =  string
}

variable "webpagecounter_frontend_version" {
  // set using environment variable PKR_VAR_webpagecounter_frontend_version
  type =  string
}

variable "secretid_service_version" {
  // set using environment variable PKR_VAR_secretid_service_version
  type =  string
}

variable "packer_version" {
  // set using environment variable PKR_VAR_packer_version
  type =  string
}

variable "vagrant_version" {
  // set using environment variable PKR_VAR_vagrant_version
  type =  string
}

variable "consul_version" {
  // set using environment variable PKR_VAR_consul_version
  type =  string
}

variable "vault_version" {
  // set using environment variable PKR_VAR_vault_version
  type =  string
}

variable "nomad_version" {
  // set using environment variable PKR_VAR_nomad_version
  type =  string
}

variable "nomad_autoscaler_version" {
  // set using environment variable PKR_VAR_nomad_autoscaler_version
  type =  string
}

variable "terraform_version" {
  // set using environment variable PKR_VAR_terraform_version
  type =  string
}

variable "consul_template_version" {
  // set using environment variable PKR_VAR_consul_template_version
  type =  string
}

variable "waypoint_version" {
  // set using environment variable PKR_VAR_waypoint_version
  type =  string
}

variable "waypoint_entrypoint_version" {
  // set using environment variable PKR_VAR_waypoint_entrypoint_version
  type =  string
}

variable "boundary_version" {
  // set using environment variable PKR_VAR_boundary_version
  type =  string
}

variable "boundary_desktop_version" {
  // set using environment variable PKR_VAR_boundary_desktop_version
  type =  string
}

variable "env_consul_version" {
  // set using environment variable PKR_VAR_env_consul_version
  type =  string
}

variable "golang_version" {
  // set using environment variable PKR_VAR_golang_version
  type =  string
}

variable "vcentre_user" {
  // set using environment variable PKR_VAR_vcentre_user
  type =  string
}

variable "vcentre_password" {
  type =  string
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}

variable "vcentre_host" {
  type =  string
}

variable "esx_host" {
  type =  string
}

source "vsphere-iso" "example" {
  CPUs                 = 1
  RAM                  = 1024
  RAM_reserve_all      = true
  boot_command         = ["<enter><wait><f6><wait><esc><wait>",
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                          "<bs><bs><bs>", "/install/vmlinuz",
                          " initrd=/install/initrd.gz", " priority=critical",
                          " locale=en_US", " file=/media/preseed.cfg",
                          "<enter>"]
  disk_controller_type = ["pvscsi"]
  floppy_files         = ["${path.root}/http/preseed.cfg"]
  guest_os_type        = "ubuntu64Guest"
  host                 = "${var.esx_host}"
  insecure_connection  = true
  convert_to_template = true
  iso_checksum = "8c5fc24894394035402f66f3824beb7234b757dd2b5531379cb310cedfdf0996"
  iso_url            = "http://cdimage.ubuntu.com/ubuntu/releases/bionic/release/ubuntu-18.04.5-server-amd64.iso"
  network_adapters {
    network_card = "vmxnet3"
    network = "VM Network"
  }
  
  ssh_private_key_file = "/Users/grazzer/.ssh/iac4me-id_rsa"
  ssh_username = "iac4me"
  storage {
    disk_size             = 32768
    disk_thin_provisioned = true
  }
  username        = "${var.vcentre_user}"
  vcenter_server  = "${var.vcentre_host}"
  datastore       = "IntelDS2"
  password        = "${var.vcentre_password}"
  vm_name         = "example"
  folder          = "packer_templates"

}


build {
  sources = ["source.vsphere-iso.example"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    inline          = ["sudo mkdir -p /usr/local/bootstrap", "sudo mkdir -p /usr/local/bootstrap/.bootstrap/live/hashistack.ie && sudo chmod 777 /usr/local/bootstrap/.bootstrap/live/hashistack.ie", "sudo mkdir -p /usr/local/bootstrap/conf/certificates", "sudo mkdir -p /usr/local/bootstrap/conf/nomad.d", "sudo mkdir -p /usr/local/bootstrap/conf/vault.d && sudo chmod -R 777 /usr/local/bootstrap", "sudo mkdir -p /usr/local/bootstrap/.bootstrap/Outputs/IntermediateCAs/consul", "sudo mkdir -p /usr/local/bootstrap/.bootstrap/Outputs/IntermediateCAs/vault", "sudo mkdir -p /usr/local/bootstrap/.bootstrap/Outputs/IntermediateCAs/nomad", "sudo mkdir -p /usr/local/bootstrap/.bootstrap/Outputs/IntermediateCAs/hashistack", "sudo mkdir -p /usr/local/bootstrap/.bootstrap/Outputs/IntermediateCAs/wpc", "sudo mkdir -p /usr/local/bootstrap/.bootstrap/Outputs/Certificates && sudo chmod -R 777 /usr/local/bootstrap/.bootstrap/Outputs/", "sudo mkdir -p /etc/nginx/conf.d/frontend/pki/tls/private/", "sudo mkdir -p /etc/nginx/conf.d/frontend/pki/tls/certs/ && sudo chmod -R 777 /etc/nginx/conf.d/frontend"]
  }

  provisioner "file" {
    destination = "/usr/local/bootstrap/"
    source      = "var.env"
  }

  provisioner "file" {
    destination = "/usr/local/bootstrap"
    only        = ["web-page-counter-vmware"]
    source      = "../scripts"
  }

  provisioner "shell" {
    execute_command   = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["scripts/packer_install_base_packages.sh"]
  }

  provisioner "inspec" {
    inspec_env_vars = [ "packer_version='${var.packer_version}'", "vagrant_version='${var.vagrant_version}'", "consul_version='${var.consul_version}'", "vault_version='${var.vault_version}'", "nomad_version='${var.nomad_version}'", "nomad_autoscaler_version=${var.nomad_autoscaler_version}", "terraform_version=${var.terraform_version}", "consul_template_version='${var.consul_template_version}'", "env_consul_version='${var.env_consul_version}'", "golang_version='${var.golang_version}'", "waypoint_version='${var.waypoint_version}'", "waypoint_entrypoint_version='${var.waypoint_entrypoint_version}'", "boundary_version='${var.boundary_version}'", "envoy_version='${var.envoy_version}'"]
    profile = "test/ImageBuild-Packer-Test"
  }



}




