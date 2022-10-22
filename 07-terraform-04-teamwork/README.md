
# Домашнее задание к занятию "7.4. Средства командной работы над инфраструктурой."

## Задача 1. Настроить terraform cloud (необязательно, но крайне желательно).

В это задании предлагается познакомиться со средством командой работы над инфраструктурой предоставляемым
разработчиками терраформа. 

1. Зарегистрируйтесь на [https://app.terraform.io/](https://app.terraform.io/).
(регистрация бесплатная и не требует использования платежных инструментов).
1. Создайте в своем github аккаунте (или другом хранилище репозиториев) отдельный репозиторий с
 конфигурационными файлами прошлых занятий (или воспользуйтесь любым простым конфигом).
1. Зарегистрируйте этот репозиторий в [https://app.terraform.io/](https://app.terraform.io/).
1. Выполните plan и apply. 

В качестве результата задания приложите снимок экрана с успешным применением конфигурации.

Шаги действий:
- Зарегестрируемся на app.terraform.io
- Выберем создание тестовой конфигурации
    ```
    terraform login 
    ```
- Зайдём на портал terraform чтобы получить токен
    ```
    https://app.terraform.io/app/settings/tokens?source=terraform-login
    ```
- Вставим токен в коммандную строку
- Скачаем тестовую конфигурацию
    ```
    git clone https://github.com/hashicorp/tfc-getting-started.git
    cd tfc-getting-started
    ./scripts/setup.sh
    ```
- Вывод `terraform plan`
    ```
    Terraform will perform the following actions:

      # fakewebservices_database.prod_db will be created
      + resource "fakewebservices_database" "prod_db" {
          + id   = (known after apply)
          + name = "Production DB"
          + size = 256
        }

      # fakewebservices_load_balancer.primary_lb will be created
      + resource "fakewebservices_load_balancer" "primary_lb" {
          + id      = (known after apply)
          + name    = "Primary Load Balancer"
          + servers = [
              + "Server 1",
              + "Server 2",
            ]
        }

      # fakewebservices_server.servers[0] will be created
      + resource "fakewebservices_server" "servers" {
          + id   = (known after apply)
          + name = "Server 1"
          + type = "t2.micro"
          + vpc  = "Primary VPC"
        }

      # fakewebservices_server.servers[1] will be created
      + resource "fakewebservices_server" "servers" {
          + id   = (known after apply)
          + name = "Server 2"
          + type = "t2.micro"
          + vpc  = "Primary VPC"
        }

      # fakewebservices_vpc.primary_vpc will be created
      + resource "fakewebservices_vpc" "primary_vpc" {
          + cidr_block = "0.0.0.0/1"
          + id         = (known after apply)
          + name       = "Primary VPC"
        }

    Plan: 5 to add, 0 to change, 0 to destroy.
    ```
- Созданная инфраструктура
    ![07-terraform-04-01.png](07-terraform-04-01.png)  
- Получаем рабочее место в Terraform Cloud
    ```
    https://app.terraform.io/app/example-org-4fb19a/workspaces/getting-started
    ```


## Задача 2. Написать серверный конфиг для атлантиса. 

Смысл задания – познакомиться с документацией 
о [серверной](https://www.runatlantis.io/docs/server-side-repo-config.html) конфигурации и конфигурации уровня 
 [репозитория](https://www.runatlantis.io/docs/repo-level-atlantis-yaml.html).

Создай `server.yaml` который скажет атлантису:
1. Укажите, что атлантис должен работать только для репозиториев в вашем github (или любом другом) аккаунте.
1. На стороне клиентского конфига разрешите изменять `workflow`, то есть для каждого репозитория можно 
будет указать свои дополнительные команды. 
1. В `workflow` используемом по-умолчанию сделайте так, что бы во время планирования не происходил `lock` состояния.

Создай `atlantis.yaml` который, если поместить в корень terraform проекта, скажет атлантису:
1. Надо запускать планирование и аплай для двух воркспейсов `stage` и `prod`.
1. Необходимо включить автопланирование при изменении любых файлов `*.tf`.

В качестве результата приложите ссылку на файлы `server.yaml` и `atlantis.yaml`.

## Задача 3. Знакомство с каталогом модулей. 

1. В [каталоге модулей](https://registry.terraform.io/browse/modules) найдите официальный модуль от aws для создания
`ec2` инстансов. 
2. Изучите как устроен модуль. Задумайтесь, будете ли в своем проекте использовать этот модуль или непосредственно 
ресурс `aws_instance` без помощи модуля?
3. В рамках предпоследнего задания был создан ec2 при помощи ресурса `aws_instance`. 
Создайте аналогичный инстанс при помощи найденного модуля.   

В качестве результата задания приложите ссылку на созданный блок конфигураций. 
