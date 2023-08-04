# Variables
variable "yc_token" {
  default = "t1.9e..."
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







# Bucket
resource "yandex_iam_service_account" "serviceaccount-bucket" {
  name        = "serviceaccount-bucket"
}
resource "yandex_resourcemanager_folder_iam_member" "roleassignment-storageeditor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.serviceaccount-bucket.id}"
}
resource "yandex_iam_service_account_static_access_key" "accesskey-bucket" {
  service_account_id = yandex_iam_service_account.serviceaccount-bucket.id
}
resource "yandex_storage_bucket" "yuri-artemiev-devops19" {
  access_key = yandex_iam_service_account_static_access_key.accesskey-bucket.access_key
  secret_key = yandex_iam_service_account_static_access_key.accesskey-bucket.secret_key
  bucket     = "yuri-artemiev-devops19"
  default_storage_class = "STANDARD"
  acl           = "public-read"
  force_destroy = "true"
  anonymous_access_flags {
    read = true
    list = true
    config_read = true
  }
}
resource "yandex_storage_object" "logo" {
  access_key = yandex_iam_service_account_static_access_key.accesskey-bucket.access_key
  secret_key = yandex_iam_service_account_static_access_key.accesskey-bucket.secret_key
  bucket     = yandex_storage_bucket.yuri-artemiev-devops19.id
  key        = "logo.png"
  source     = "logo.png"
}






# Compute instance group
## Instance group for network load balancer
resource "yandex_iam_service_account" "serviceaccount-vmgroup" {
  name        = "serviceaccount-vmgroup"
}
resource "yandex_resourcemanager_folder_iam_member" "roleassignment-editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.serviceaccount-vmgroup.id}"
}
resource "yandex_compute_instance_group" "vmgroup-networklb" {
  name               = "vmgroup-networklb"
  folder_id          = var.yc_folder_id
  service_account_id = "${yandex_iam_service_account.serviceaccount-vmgroup.id}"
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
      }
    }
    network_interface {
      network_id = "${yandex_vpc_network.network-netology.id}"
      subnet_ids = ["${yandex_vpc_subnet.public.id}"]
    }
    metadata = {
      ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
      user-data = "#!/bin/bash\n cd /var/www/html\n echo \"<html><h1>Network load balanced web-server</h1><img src='https://${yandex_storage_bucket.yuri-artemiev-devops19.bucket_domain_name}/${yandex_storage_object.logo.key}'></html>\" > index.html"
    }
    labels = {
      group = "network-load-balanced"
    }
  }
  scale_policy {
    fixed_scale {
      size = 3
    }
  }
  allocation_policy {
    zones = [var.yc_region]
  }
  deploy_policy {
    max_unavailable = 2
    max_expansion   = 1
  }
  load_balancer {
    target_group_name        = "targtet-networklb"
  }
  health_check {
    interval = 15
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
    http_options {
      path = "/"
      port = 80
    }
  }
}
## Instance group for application load balancer
resource "yandex_compute_instance_group" "vmgroup-applicationlb" {
  name               = "vmgroup-applicationlb"
  folder_id          = var.yc_folder_id
  service_account_id = "${yandex_iam_service_account.serviceaccount-vmgroup.id}"
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
      }
    }
    network_interface {
      network_id = "${yandex_vpc_network.network-netology.id}"
      subnet_ids = ["${yandex_vpc_subnet.public.id}"]
    }
    metadata = {
      ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
      user-data = "#!/bin/bash\n cd /var/www/html\n echo \"<html><h1>Application load balanced server</h1><img src='https://${yandex_storage_bucket.yuri-artemiev-devops19.bucket_domain_name}/${yandex_storage_object.logo.key}'></html>\" > index.html"
    }
    labels = {
      group = "application-load-balanced"
    }
  }
  scale_policy {
    fixed_scale {
      size = 3
    }
  }
  allocation_policy {
    zones = [var.yc_region]
  }
  deploy_policy {
    max_unavailable = 2
    max_expansion   = 1
  }
  application_load_balancer {
    target_group_name        = "target-applicationlb"
  }
  health_check {
    interval = 15
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
    http_options {
      path = "/"
      port = 80
    }
  }
}







# Network
## VPC
resource "yandex_vpc_network" "network-netology" {
  name = "network-netology"
}
## Public subnet
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.yc_region
  network_id     = yandex_vpc_network.network-netology.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
## Network Load balancer
resource "yandex_lb_network_load_balancer" "loadbalacner-networklb" {
  name = "loadbalacner-networklb"
  listener {
    name = "loadbalancer-networklb-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_compute_instance_group.vmgroup-networklb.load_balancer.0.target_group_id
    healthcheck {
      name = "http"
      interval = 10
      timeout = 5
      unhealthy_threshold = 2
      healthy_threshold = 5
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
## Application Load Balancer
resource "yandex_alb_backend_group" "backendgroup-applicationlb" {
  name                     = "backendgroup"
  http_backend {
    name                   = "http-backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_compute_instance_group.vmgroup-applicationlb.application_load_balancer.0.target_group_id]
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 5
      unhealthy_threshold  = 2
      http_healthcheck {
        path               = "/"
      }
    }
  }
}
resource "yandex_alb_http_router" "httprouter-applicationlb" {
  name   = "httprouter-applicationlb"
}
resource "yandex_alb_virtual_host" "virtualhost-applicationlb" {
  name           = "virtualhost-applicationlb"
  http_router_id = yandex_alb_http_router.httprouter-applicationlb.id
  route {
    name = "http-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backendgroup-applicationlb.id
        timeout          = "5s"
      }
    }
  }
}
resource "yandex_alb_load_balancer" "loadbalancer-applicationlb" {
  name        = "loadbalancer-applicationlb"
  network_id  = yandex_vpc_network.network-netology.id
  allocation_policy {
    location {
      zone_id   = var.yc_region
      subnet_id = yandex_vpc_subnet.public.id
    }
  }
  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.httprouter-applicationlb.id
      }
    }
  }
}






# Output
output "ipaddress_networklb" {
  value = yandex_compute_instance_group.vmgroup-networklb.instances[*].network_interface[0].ip_address
}
output "ipaddress_applicationlb" {
  value = yandex_compute_instance_group.vmgroup-applicationlb.instances[*].network_interface[0].ip_address
}
output "pic_url" {
  value = "https://${yandex_storage_bucket.yuri-artemiev-devops19.bucket_domain_name}/${yandex_storage_object.logo.key}"
}
output "loadbalancer_netowrklb_address" {
  value = yandex_lb_network_load_balancer.loadbalacner-networklb.listener.*.external_address_spec[0].*.address
}
output "loadbalancer_appliactionlb_address" {
  value = yandex_alb_load_balancer.loadbalancer-applicationlb.listener.*.endpoint[0].*.address[0].*.external_ipv4_address
}