# Домашнее задание к занятию "7.2. Облачные провайдеры и синтаксис Terraform."

Зачастую разбираться в новых инструментах гораздо интересней понимая то, как они работают изнутри. 
Поэтому в рамках первого *необязательного* задания предлагается завести свою учетную запись в AWS (Amazon Web Services) или Yandex.Cloud.
Идеально будет познакомится с обоими облаками, потому что они отличаются. 


## Задача 1 (Вариант с Yandex.Cloud). Регистрация в ЯО и знакомство с основами (необязательно, но крайне желательно).

1. Подробная инструкция на русском языке содержится [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
2. Обратите внимание на период бесплатного использования после регистрации аккаунта. 
3. Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки
базового терраформ конфига.
4. Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы 
не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.

Порядок действий:  

- Регистрация на Яндекс Облаке по адресу console.cloud.yandex.ru  
- Создаём платёжный аккаунт с промо-кодом  
- Скачаем и установим утилиту `yc`  
    - `curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash`  
- Запустим утилиту `yc`:    
    - `yc init`  
    - Получим OAuth токен по адресу в браузере `https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb`  
    - В утилите `yc`    
        - Вставим токен  
        - Выберем папку в Яндекс Облаке  
        - Выберем создание Compute по-умолчанию  
        - Выберем зону в Яндекс Облаке  
    - Проверим созданные настройки Яндекс Облака    
        - `yc config list`
            ```
            token: y0_A...
            cloud-id: b1gjd8gta6ntpckrp97r
            folder-id: b1gcthk9ak11bmpnbo7d
            compute-default-zone: ru-central1-a
            ```
- Получим IAM-токен  
    ```
    yc iam create-token
    ```
- Сохраним токен и параметры в переменную окружения  
    ```
    export YC_TOKEN=$(yc iam create-token)
    export YC_CLOUD_ID=$(yc config get cloud-id)
    export YC_FOLDER_ID=$(yc config get folder-id)
    export YC_ZONE=$(yc config get compute-default-zone)
    ```
- Настроем провайдер terraform  
    ```
    nano ~/.terraformrc
    ```
    ```
    provider_installation {
      network_mirror {
        url = "https://terraform-mirror.yandexcloud.net/"
        include = ["registry.terraform.io/*/*"]
      }
      direct {
        exclude = ["registry.terraform.io/*/*"]
      }
    }
    ```
- Сгенерируем SSH ключи на локальной машине  
    ```
    ssh-keygen
    ```
- Создадим конфигурацию terraform  
    ```
    mkdir -p ~/terraform
    nano ~/terraform/main.tf
    ```
    ```
    terraform {
      required_providers {
        yandex = {
          source = "yandex-cloud/yandex"
        }
      }
      required_version = ">= 0.13"
    }

    provider "yandex" {
      zone = "ru-central1-a"
    }
    ```
- Инициализируем провайдер  
    ```
    terraform init
    ```




## Задача 2. Создание aws ec2 или yandex_compute_instance через терраформ. 

1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
2. Зарегистрируйте провайдер 
   1. для [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). В файл `main.tf` добавьте
   блок `provider`, а в `versions.tf` блок `terraform` с вложенным блоком `required_providers`. Укажите любой выбранный вами регион 
   внутри блока `provider`.
   2. либо для [yandex.cloud](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs). Подробную инструкцию можно найти 
   [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали
их в виде переменных окружения. 
4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
5. В файле `main.tf` создайте рессурс 
   1. либо [ec2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).
   Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке 
   `Example Usage`, но желательно, указать большее количество параметров.
   2. либо [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
6. Также в случае использования aws:
   1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
   2. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент: 
       * AWS account ID,
       * AWS user ID,
       * AWS регион, который используется в данный момент, 
       * Приватный IP ec2 инстансы,
       * Идентификатор подсети в которой создан инстанс.  
7. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок. 


В качестве результата задания предоставьте:
1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?
    - Можнос собрать образ с помощью packer
2. Ссылку на репозиторий с исходной конфигурацией терраформа.  
    - https://github.com/yuri-artemiev/devops-netology/tree/main/07-terraform-02-syntax


Последовательность действий:  
- Отредактируем файл конфигурации terraform  
    ```
    nano ~/terraform/main.tf
    ```
    ```
    terraform {
      required_providers {
        yandex = {
          source = "yandex-cloud/yandex"
        }
      }
      required_version = ">= 0.13"
    }

    provider "yandex" {
      cloud_id  = "b1gjd8gta6ntpckrp97r"
      folder_id = "b1gcthk9ak11bmpnbo7d"
      zone = "ru-central1-a"
    }

    resource "yandex_compute_instance" "vm-1" {
      name = "terraform1"

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


    output "internal_ip_address_vm_1" {
      value = yandex_compute_instance.vm-1.network_interface.0.ip_address
    }

    output "external_ip_address_vm_1" {
      value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
    }

    ```
- Проверим конфигурацию terraform  
    ```
    terraform validate
    ```
- Подготовим план terraform  
    ```
    terraform plan
    ```
- Создадим ресурсы в Яндекс Облаке  
    ```
    terraform apply --auto-approve
    ```
- Проверим, что виртуальная машина в Яндекс Облаке создалась с помощью утилиты yc
    ```
    yc compute instance list
    ```
    ```
    +----------------------+------------+---------------+---------+--------------+---------------+
    |          ID          |    NAME    |    ZONE ID    | STATUS  | EXTERNAL IP  |  INTERNAL IP  |
    +----------------------+------------+---------------+---------+--------------+---------------+
    | fhmad4e2areeph3usr3m | terraform1 | ru-central1-a | RUNNING | 51.250.9.157 | 192.168.10.13 |
    +----------------------+------------+---------------+---------+--------------+---------------+
    ```
- Удалим ресурсы в Яндекс Облаке  
    ```
    terraform destroy --auto-approve
    ```


