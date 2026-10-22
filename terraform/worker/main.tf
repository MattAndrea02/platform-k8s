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

resource "libvirt_pool" "base-image-pool" {
  name = "base-image-pool"
  type = "dir"
  target = {
    path = "/data/libvirt/base-image-pool"
  }
}
resource "libvirt_pool" "cloud-init-pool" {
  name = "cloud-init-pool"
  type = "dir"
  target = {
    path = "/data/libvirt/cloud-init-pool"
  }
}

resource "libvirt_pool" "vm_disks" {
  name = "vm-disks"
  type = "dir"

  target = {
    path = "/data/libvirt/vm-disks"
  }
}
