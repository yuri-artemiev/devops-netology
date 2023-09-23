# Variables
variable "yc_token" {}
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
  v4_cidr_blocks = ["10.1.10.0/24"]
  zone           = "ru-central1-a"
  name           = "subnet-prod-a"
  folder_id      = "${yandex_resourcemanager_folder.folder-prod.id}"
  network_id     = "${yandex_vpc_network.network-prod.id}"
}
resource "yandex_vpc_subnet" "subnet-prod-b" {
  v4_cidr_blocks = ["10.1.20.0/24"]
  zone           = "ru-central1-b"
  name           = "subnet-prod-b"
  folder_id      = "${yandex_resourcemanager_folder.folder-prod.id}"
  network_id     = "${yandex_vpc_network.network-prod.id}"
}
resource "yandex_vpc_subnet" "subnet-prod-c" {
  v4_cidr_blocks = ["10.1.30.0/24"]
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
    memory = 4
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
    memory = 4
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
    memory = 4
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
    memory = 4
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


# Output
output "internal-ip-address-virtualmachine-master" {
  value = "${yandex_compute_instance.virtualmachine-master.network_interface.0.ip_address}"
}
output "fqdn-virtualmachine-master" {
  value = "${yandex_compute_instance.virtualmachine-master.fqdn}"
}



# Kubespray preparation
## Ansible inventory for Kuberspray
resource "local_file" "ansible-inventory-kubespray" {
  content = <<EOF
all:
  hosts:
    ${yandex_compute_instance.virtualmachine-master.fqdn}:
      ansible_host: ${yandex_compute_instance.virtualmachine-master.network_interface.0.ip_address}
      ip: ${yandex_compute_instance.virtualmachine-master.network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.virtualmachine-master.network_interface.0.ip_address}
    ${yandex_compute_instance.virtualmachine-worker-a.fqdn}:
      ansible_host: ${yandex_compute_instance.virtualmachine-worker-a.network_interface.0.ip_address}
      ip: ${yandex_compute_instance.virtualmachine-worker-a.network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.virtualmachine-worker-a.network_interface.0.ip_address}
    ${yandex_compute_instance.virtualmachine-worker-b.fqdn}:
      ansible_host: ${yandex_compute_instance.virtualmachine-worker-b.network_interface.0.ip_address}
      ip: ${yandex_compute_instance.virtualmachine-worker-b.network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.virtualmachine-worker-b.network_interface.0.ip_address}
    ${yandex_compute_instance.virtualmachine-worker-c.fqdn}:
      ansible_host: ${yandex_compute_instance.virtualmachine-worker-c.network_interface.0.ip_address}
      ip: ${yandex_compute_instance.virtualmachine-worker-c.network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.virtualmachine-worker-c.network_interface.0.ip_address}
  children:
    kube_control_plane:
      hosts:
        ${yandex_compute_instance.virtualmachine-master.fqdn}:
    kube_node:
      hosts:
        ${yandex_compute_instance.virtualmachine-worker-a.fqdn}:
        ${yandex_compute_instance.virtualmachine-worker-b.fqdn}:
        ${yandex_compute_instance.virtualmachine-worker-c.fqdn}:
    etcd:
      hosts:
        ${yandex_compute_instance.virtualmachine-master.fqdn}:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
  EOF
  filename = "../../ansible/workspace-prod/ansible-inventory-kubespray"
  depends_on = [yandex_compute_instance.virtualmachine-master, yandex_compute_instance.virtualmachine-worker-a, yandex_compute_instance.virtualmachine-worker-b, yandex_compute_instance.virtualmachine-worker-c]
}

## Ansible inventory for virtualmachine-master
resource "local_file" "ansible-inventory-virtualmachine-master" {
  content = <<-DOC
    kuber:
      hosts:
        ${yandex_compute_instance.virtualmachine-master.fqdn}:
          ansible_host: ${yandex_compute_instance.virtualmachine-master.network_interface.0.nat_ip_address}
    DOC
  filename = "../../ansible/workspace-prod/ansible-inventory-virtualmachine-master"
  depends_on = [yandex_compute_instance.virtualmachine-master, yandex_compute_instance.virtualmachine-worker-a, yandex_compute_instance.virtualmachine-worker-b, yandex_compute_instance.virtualmachine-worker-c]
}

## Ansible inventory for Kubespray configuration
resource "null_resource" "ansible-kubespray-k8s-config" {
  provisioner "local-exec" {
    command = "wget --quiet https://raw.githubusercontent.com/kubernetes-sigs/kubespray/master/inventory/sample/group_vars/k8s_cluster/k8s-cluster.yml -O ../../ansible/workspace-prod/k8s-cluster.yml"
  }
  depends_on = [yandex_compute_instance.virtualmachine-master, yandex_compute_instance.virtualmachine-worker-a, yandex_compute_instance.virtualmachine-worker-b, yandex_compute_instance.virtualmachine-worker-c]
}
resource "null_resource" "ansible-kubespray-k8s-config-add" {
  provisioner "local-exec" {
    command = "echo 'supplementary_addresses_in_ssl_keys: [ ${yandex_compute_instance.virtualmachine-master.network_interface.0.nat_ip_address} ]' >> ../../ansible/workspace-prod/k8s-cluster.yml"
  }
  depends_on = [null_resource.ansible-kubespray-k8s-config]
}

## Script for installation of Kubernetes with Kubespray
resource "local_file" "install-kubernetes-with-kubespray" {
  content = <<-DOC
    #!/bin/bash
    set -euxo pipefail
    export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ansible-inventory-virtualmachine-master prepare-master.yml
    sleep 20
    ssh ubuntu@${yandex_compute_instance.virtualmachine-master.network_interface.0.nat_ip_address} 'export ANSIBLE_HOST_KEY_CHECKING=False; export ANSIBLE_ROLES_PATH=/home/ubuntu/kubespray/roles:/home/ubuntu/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles; ansible-playbook -i /home/ubuntu/kubespray/inventory/mycluster/hosts.yaml -u ubuntu -b -v --private-key=/home/ubuntu/.ssh/id_rsa /home/ubuntu/kubespray/cluster.yml'
    sleep 20
    export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ansible-inventory-virtualmachine-master get-kubeconfig.yml
    sleep 5
    sed -i -e 's,server: https://127.0.0.1:6443,server: https://${yandex_compute_instance.virtualmachine-master.network_interface.0.nat_ip_address}:6443,g'  ~/.kube/config
    DOC
  filename = "../../ansible/workspace-prod/install-kubernetes-with-kubespray.sh"
  depends_on = [yandex_compute_instance.virtualmachine-master, yandex_compute_instance.virtualmachine-worker-a, yandex_compute_instance.virtualmachine-worker-b, yandex_compute_instance.virtualmachine-worker-c]
}

## Set execution bit on install script
resource "null_resource" "chmod" {
  provisioner "local-exec" {
    command = "chmod 755 ../../ansible/workspace-prod/install-kubernetes-with-kubespray.sh"
  }
  depends_on = [local_file.install-kubernetes-with-kubespray]
}