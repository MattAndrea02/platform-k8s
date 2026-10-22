terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

// Connect to local libvirt
provider "libvirt" {
  uri = "qemu:///system"
}

locals {
  base_image_pool = "base-image-pool"
  cloud_init_pool = "cloud-init-pool"
  vm_disk_pool    = "vm-disks"
}
