terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "s3-terraform"
    region     = "ru-central1"
    key        = "terraform.tfstate"
    access_key = "YCAJEMPlx5hXK5stLB3dXt_Nd"
    secret_key = "YCMK..."

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  zone = "ru-central1-a"
}


resource "yandex_compute_instance" "vm-1-count" {
  name = "${terraform.workspace}-count-${count.index}"
  count = local.vm-1-count-dic[terraform.workspace]

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "yandex_compute_instance" "vm-2-foreach" {
  name = "${terraform.workspace}-foreach-${each.key}"
  for_each = local.vm-2-foreach-dic[terraform.workspace]

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  lifecycle {
    create_before_destroy = true
  }
}


locals {
  vm-1-count-dic = {
    stage = 1
    prod = 2
  }

  vm-2-foreach-dic = {
    stage = toset(["1"])
    prod = toset(["1", "2"])
  }

}


resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}


output "internal_ip_address_vm_1_count" {
  value = yandex_compute_instance.vm-1-count[*].network_interface.0.ip_address
}

output "external_ip_address_vm_1_count" {
  value = yandex_compute_instance.vm-1-count[*].network_interface.0.nat_ip_address
}

output "internal_ip_address_vm_2_foreach" {
  value = values(yandex_compute_instance.vm-2-foreach)[*].network_interface.0.ip_address
}

output "external_ip_address_vm_2_foreach" {
  value = values(yandex_compute_instance.vm-2-foreach)[*].network_interface.0.nat_ip_address
}
