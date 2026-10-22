locals {
  ssh_public_key = trimspace(
    file(pathexpand("~/.ssh/id_rsa.pub"))
  )
}

resource "libvirt_cloudinit_disk" "worker_cloudinit" {
  name = "worker-1-cloudinit"

  user_data = templatefile("${path.module}/cloud_init.cfg", {
    hostname       = "worker-1"
    ssh_public_key = local.ssh_public_key
  })

  meta_data = yamlencode({
    instance-id    = "worker-1"
    local-hostname = "worker-1"
  })
}

resource "libvirt_volume" "worker_cloudinit_iso" {
  name = "worker-1-cloudinit.iso"
  pool = libvirt_pool.cloud-init-pool.name

  target = {
    format = {
      type = "iso"
    }
  }

  create = {
    content = {
      url = libvirt_cloudinit_disk.worker_cloudinit.path
    }
  }
}

resource "libvirt_volume" "debian_base" {
  name = "debian-13-base.qcow2"
  pool = libvirt_pool.base-image-pool.name

  target = {
    format = {
      type = "qcow2"
    }
  }

  create = {
    content = {
      url = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
    }
  }
}

resource "libvirt_volume" "worker_disk" {
  name     = "worker-1.qcow2"
  pool     = libvirt_pool.vm_disks.name
  capacity = 21474836480 # 20 GiB

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.debian_base.path

    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_domain" "k8s-worker" {
  count = 1

  name        = "worker-${count.index + 1}"
  memory      = 3096
  memory_unit = "MiB"
  vcpu        = 2
  type        = "kvm"

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    boot_devices = [
      { dev = "hd" },
      { dev = "network" }
    ]
  }

  features = {
    acpi = true
    apic = {}
  }

  devices = {
    consoles = [
      {
        type = "pty"
        target = {
          type = "virtio"
          port = 0
        }
      }
    ]

    disks = [
      {
        source = {
          file = {
            file = libvirt_volume.worker_disk.path
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }

        driver = {
          name = "qemu"
          type = "qcow2"
        }
      },

      {
        device = "cdrom"

        source = {
          file = {
            file = libvirt_volume.worker_cloudinit_iso.path
          }
        }

        target = {
          dev = "sda"
          bus = "sata"
        }

        driver = {
          name = "qemu"
          type = "raw"
        }

        readonly = true
      }

    ]
    interfaces = [
      {
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = "default"
          }
        }
      }
    ]
  }

}

