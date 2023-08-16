# Variables
variable "yc_token" {
  default = "t1.9..."
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
}
provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone = var.yc_region
}









# VPC networks
resource "yandex_vpc_network" "network-netology" {
  name = "network-netology"
}
resource "yandex_vpc_subnet" "private-a" {
  name           = "private-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
}
resource "yandex_vpc_subnet" "private-b" {
  name           = "private-b"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-netology.id
}
resource "yandex_vpc_subnet" "private-c" {
  name           = "private-c"
  v4_cidr_blocks = ["192.168.30.0/24"]
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-netology.id
}
resource "yandex_vpc_security_group" "network-securitygroup" {
  name        = "network-securitygroup"
  network_id  = yandex_vpc_network.network-netology.id
  ingress {
    protocol       = "TCP"
    description    = "Входящий траффик кластера"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3306
  }
}
resource "yandex_vpc_subnet" "public-a" {
  name           = "public-a"
  v4_cidr_blocks = ["192.168.40.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
}
resource "yandex_vpc_subnet" "public-b" {
  name           = "public-b"
  v4_cidr_blocks = ["192.168.50.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-netology.id
}
resource "yandex_vpc_subnet" "public-c" {
  name           = "public-c"
  v4_cidr_blocks = ["192.168.60.0/24"]
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-netology.id
}






















# MySQL cluster
resource "yandex_mdb_mysql_cluster" "mysql-cluster" {
  name               = "mysql-cluster"
  environment        = "PRESTABLE"
  network_id         = yandex_vpc_network.network-netology.id
  version            = "8.0"
  security_group_ids = [yandex_vpc_security_group.network-securitygroup.id]
  deletion_protection = true
  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = "network-ssd"
    disk_size          = "20"
  }
  maintenance_window {
    type = "ANYTIME"
  }
  backup_window_start {
    hours   = "23"
    minutes = "59"
  }
  host {
    name      = "mysql-node-a"
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.private-a.id
  }
  host {
    name      = "mysql-node-b"
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.private-b.id
  }
  host {
    name      = "mysql-node-c"
    zone      = "ru-central1-c"
    subnet_id = yandex_vpc_subnet.private-c.id
  }
}
resource "yandex_mdb_mysql_database" "netology_db" {
  cluster_id = yandex_mdb_mysql_cluster.mysql-cluster.id
  name       = "netology_db"
}
resource "yandex_mdb_mysql_user" "mysql_user" {
  cluster_id = yandex_mdb_mysql_cluster.mysql-cluster.id
  name       = "mysql_user"
  password   = "mysql_password"
  permission {
    database_name = yandex_mdb_mysql_database.netology_db.name
    roles         = ["ALL"]
  }
}




















# Kubernetes cluster
resource "yandex_iam_service_account" "kubernetes-serviceaccount" {
  name        = "kubernetes-serviceaccount"
}
resource "yandex_resourcemanager_folder_iam_member" "kubernetes-roleassignment-admin" {
  folder_id = var.yc_folder_id
  role      = "k8s.admin"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes-serviceaccount.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "kubernetes-roleassignment-clusteragent" {
  folder_id = var.yc_folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes-serviceaccount.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "kubernetes-roleassignment-vpcpublicadmin" {
  folder_id = var.yc_folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes-serviceaccount.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "kubernetes-roleassignment-imagespuller" {
  folder_id = var.yc_folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes-serviceaccount.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "kubernetes-roleassignment-loadbalanceradmin" {
  folder_id = var.yc_folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes-serviceaccount.id}"
}
resource "yandex_kms_symmetric_key" "encryption-key" {
  name              = "encryption-key"
  default_algorithm = "AES_256"
}
resource "yandex_kms_symmetric_key_iam_binding" "kubernetes-roleassignment-keyviewer" {
  symmetric_key_id = yandex_kms_symmetric_key.encryption-key.id
  role             = "viewer"
  members          = [
    "serviceAccount:${yandex_iam_service_account.kubernetes-serviceaccount.id}"
  ]
}
resource "yandex_kubernetes_cluster" "kubernetes-cluster" {
  name               = "kubernetes-cluster"
  network_id         = yandex_vpc_network.network-netology.id
  cluster_ipv4_range = "10.1.0.0/16"
  service_ipv4_range = "10.2.0.0/16"
  master {
    version   = "1.23"
    public_ip = true
    regional {
      region = "ru-central1"
      location {
        zone      = yandex_vpc_subnet.public-a.zone
        subnet_id = yandex_vpc_subnet.public-a.id
      }
      location {
        zone      = yandex_vpc_subnet.public-b.zone
        subnet_id = yandex_vpc_subnet.public-b.id
      }
      location {
        zone      = yandex_vpc_subnet.public-c.zone
        subnet_id = yandex_vpc_subnet.public-c.id
      }
    }
  }
  service_account_id      = yandex_iam_service_account.kubernetes-serviceaccount.id
  node_service_account_id = yandex_iam_service_account.kubernetes-serviceaccount.id
  kms_provider {
    key_id = yandex_kms_symmetric_key.encryption-key.id
  }
}
resource "yandex_kubernetes_node_group" "kubernetes-nodegroup-a" {
  cluster_id  = yandex_kubernetes_cluster.kubernetes-cluster.id
  name        = "kubernetes-nodegroup-a"
  instance_template {
    platform_id = "standard-v2"
    container_runtime {
      type = "containerd"
    }
    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.public-a.id}"]
    }
    resources {
      memory = 2
      cores  = 2
    }
    scheduling_policy {
      preemptible = true
    }
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
  }
  scale_policy {
    auto_scale {
      initial = 1
      max     = 2
      min     = 1
    }
  }
  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }
}
resource "yandex_kubernetes_node_group" "kubernetes-nodegroup-b" {
  cluster_id  = yandex_kubernetes_cluster.kubernetes-cluster.id
  name        = "kubernetes-nodegroup-b"
  instance_template {
    platform_id = "standard-v2"
    container_runtime {
      type = "containerd"
    }
    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.public-b.id}"]
    }
    resources {
      memory = 2
      cores  = 2
    }
    scheduling_policy {
      preemptible = true
    }
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
  }
  scale_policy {
    auto_scale {
      initial = 1
      max     = 2
      min     = 1
    }
  }
  allocation_policy {
    location {
      zone = "ru-central1-b"
    }
  }
}
resource "yandex_kubernetes_node_group" "kubernetes-nodegroup-c" {
  cluster_id  = yandex_kubernetes_cluster.kubernetes-cluster.id
  name        = "kubernetes-nodegroup-c"
  instance_template {
    platform_id = "standard-v2"
    container_runtime {
      type = "containerd"
    }
    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.public-c.id}"]
    }
    resources {
      memory = 2
      cores  = 2
    }
    scheduling_policy {
      preemptible = true
    }
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
  }
  scale_policy {
    auto_scale {
      initial = 1
      max     = 2
      min     = 1
    }
  }
  allocation_policy {
    location {
      zone = "ru-central1-c"
    }
  }
}














# Output
output "mysql-master-address" {
  value       = "c-${yandex_mdb_mysql_cluster.mysql-cluster.id}.rw.mdb.yandexcloud.net"
}
output "mysql-nodes" {
  value       = yandex_mdb_mysql_cluster.mysql-cluster.host.*.fqdn
}
output "kubernetes_cluster_ip" {
  value       = yandex_kubernetes_cluster.kubernetes-cluster.master[0].external_v4_endpoint
}
output "kubernetes_cluster_id" {
  value       = yandex_kubernetes_cluster.kubernetes-cluster.id
}
output "kubernetes_certificate_base64" {
  value       = base64encode(yandex_kubernetes_cluster.kubernetes-cluster.master[0].cluster_ca_certificate)
}
output "kubernetes_user" {
  value       = yandex_iam_service_account.kubernetes-serviceaccount.name
}


