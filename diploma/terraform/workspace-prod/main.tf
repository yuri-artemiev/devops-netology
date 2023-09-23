# Variables
variable "yc_token" {
  default = "t1.9euelZqTm82cipiJmonLl56MjZaYj-3rnpWax8yRlImYyYuVnc2Yzomcko7l8_c5WCJY-e9NYhR5_d3z93kGIFj5701iFHn9zef1656VmsjGncbGjpiRj82alIzHjImJ7_zF656VmsjGncbGjpiRj82alIzHjImJ.zh2M9k0cOkMoUtG61iXNTdSbIvKUCInQJUg6ueEeP8S6HMJTnRW5iXj-Pm15QBObNSu1cmpJmN19eLYEy_LXDw"
}
variable "yc_cloud_id" {
  default = "b1gjd8gta6ntpckrp97r"
}
variable "yc_folder_id" {
  default = "b1gcthk9ak11bmpnbo7d"
}
variable "yc_region" {
  default = "ru-central1-a"
}


# Terraform providers
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  cloud {
    organization = "yuri-artemiev"
    workspaces {
      name = "workspace-prod"
    }
  }
}
provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone = var.yc_region
}




# Folder
## Folder for prod
resource "yandex_resourcemanager_folder" "folder-prod" {
  cloud_id    = var.yc_cloud_id
  name        = "folder-prod"
}



# Service account
## Service account for prod
resource "yandex_iam_service_account" "serviceaccount-prod" {
  folder_id = "${yandex_resourcemanager_folder.folder-prod.id}"
  name = "serviceaccount-prod"
}
resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = "${yandex_resourcemanager_folder.folder-prod.id}"
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.serviceaccount-prod.id}"
}






# Network
resource "yandex_vpc_network" "network-prod" {
  name = "network-prod"
  folder_id = "${yandex_resourcemanager_folder.folder-prod.id}"
}
resource "yandex_vpc_subnet" "subnet-prod-a" {
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  name           = "subnet-prod-a"
  folder_id      = "${yandex_resourcemanager_folder.folder-prod.id}"
  network_id     = "${yandex_vpc_network.network-prod.id}"
}
resource "yandex_vpc_subnet" "subnet-prod-b" {
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-b"
  name           = "subnet-prod-b"
  folder_id      = "${yandex_resourcemanager_folder.folder-prod.id}"
  network_id     = "${yandex_vpc_network.network-prod.id}"
}
resource "yandex_vpc_subnet" "subnet-prod-c" {
  v4_cidr_blocks = ["192.168.30.0/24"]
  zone           = "ru-central1-c"
  name           = "subnet-prod-c"
  folder_id      = "${yandex_resourcemanager_folder.folder-prod.id}"
  network_id     = "${yandex_vpc_network.network-prod.id}"
}






# Virtual machines
## Kubernetes master
resource "yandex_compute_instance" "virtualmachine-master" {
  name = "virtualmachine-master"
  hostname = "virtualmachine-master.ru-central1.internal"
  zone      = "ru-central1-a"
  folder_id      = "${yandex_resourcemanager_folder.folder-prod.id}"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8g5aftj139tv8u2mo1"
      size = "20"
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-prod-a.id}"
    nat       = true
  }
  metadata = {
    ssh-keys  = "ubuntu:${file("id_rsa.pub")}"
  }
}
## Kubernetes workers
resource "yandex_compute_instance" "virtualmachine-worker-a" {
  name = "virtualmachine-worker-a"
  hostname = "virtualmachine-worker-a.ru-central1.internal"
  zone      = "ru-central1-a"
  folder_id      = "${yandex_resourcemanager_folder.folder-prod.id}"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8g5aftj139tv8u2mo1"
      size = "10"
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-prod-a.id}"
    nat       = true
  }
  metadata = {
    ssh-keys  = "ubuntu:${file("id_rsa.pub")}"
  }
}
resource "yandex_compute_instance" "virtualmachine-worker-b" {
  name = "virtualmachine-worker-b"
  hostname = "virtualmachine-worker-b.ru-central1.internal"
  zone      = "ru-central1-b"
  folder_id      = "${yandex_resourcemanager_folder.folder-prod.id}"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8g5aftj139tv8u2mo1"
      size = "10"
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-prod-b.id}"
    nat       = true
  }
  metadata = {
    ssh-keys  = "ubuntu:${file("id_rsa.pub")}"
  }
}
resource "yandex_compute_instance" "virtualmachine-worker-c" {
  name = "virtualmachine-worker-c"
  hostname = "virtualmachine-worker-c.ru-central1.internal"
  zone      = "ru-central1-c"
  folder_id      = "${yandex_resourcemanager_folder.folder-prod.id}"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8g5aftj139tv8u2mo1"
      size = "10"
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-prod-c.id}"
    nat       = true
  }
  metadata = {
    ssh-keys  = "ubuntu:${file("id_rsa.pub")}"
  }
}