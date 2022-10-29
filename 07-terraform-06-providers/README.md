# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

Бывает, что 
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобиться использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.   

## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   
    - Файл `internal/provider/provider.go`  
    `ResourcesMap: map[string]*schema.Resource`  
    [Ресурсы|https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L930]  
    `DataSourcesMap: map[string]*schema.Resource`  
    [Источник данных|https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L419]  
    
1. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
        - Файл `internal/service/sqs/name.go`   
        В последеней версии провайдера, имя из URL разделяется на три части по символу `/`. Если частей не три - возникает ошибка  
        `if len(parts) != 3`  
        [name.go|https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/service/sqs/name.go#L20]  
    * Какая максимальная длина имени? 
        - В новой версии не смог найти
    * Какому регулярному выражению должно подчиняться имя? 
        - В новой версии не смог найти
    
## Задача 2. (Не обязательно) 
В рамках вебинара и презентации мы разобрали как создать свой собственный провайдер на примере кофемашины. 
Также вот официальная документация о создании провайдера: 
[https://learn.hashicorp.com/collections/terraform/providers](https://learn.hashicorp.com/collections/terraform/providers).

1. Проделайте все шаги создания провайдера.
2. В виде результата приложение ссылку на исходный код.
3. Попробуйте скомпилировать провайдер, если получится то приложите снимок экрана с командой и результатом компиляции.   

- Установим Docker  
    ```
    apt-get install ca-certificates curl gnupg lsb-release
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    ```
- Скопируем репозиторий `learn-terraform-hashicups-provider`  
    ```
    git clone https://github.com/hashicorp/learn-terraform-hashicups-provider
    cd learn-terraform-hashicups-provider
    ```
- Запустим Docker контейнеры
    ```
    cd docker_compose
    docker compose up
    ```
- Проверим доступность сервиса
    ```
    curl localhost:19090/health
    ```
    ```
    ok
    ```
- Скачаем HashiCups провайдер
    ```
    curl -LO https://github.com/hashicorp/terraform-provider-hashicups/releases/download/v0.3.1/terraform-provider-hashicups_0.3.1_linux_amd64.zip
    ```
- Создадим директорию для плагинов
    ```
    mkdir -p ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.3.1/linux_amd64
    ```
- Распакуем провайдер в директорию
    ```
    unzip terraform-provider-hashicups_0.3.1_linux_amd64.zip -d ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.3.1/linux_amd64
    chmod +x ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.3.1/linux_amd64/terraform-provider-hashicups_v0.3.1
    ```
- Создадим пользователя через провайдер
    ```
    curl -X POST localhost:19090/signup -d '{"username":"netology", "password":"test123"}'
    ```
    ```
    docker_compose-api-1  | 2022-10-29T14:12:26.888Z [INFO]  Handle User | signup
    {"UserID":1,"Username":"netology","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NjcxMzkxNDYsInVzZXJfaWQiOjEsInVzZXJuYW1lIjoibmV0b2xvZ3kifQ.Nvt3Al5e-eMN3XZZs-vdeo_d8Xmz4gR9_nnnpODsD_U"}
    ```
- Авторизируемся в HashiCup с помощью созданного пользователя
    ```
    curl -X POST localhost:19090/signin -d '{"username":"netology", "password":"test123"}'
    ```
    ```
    docker_compose-api-1  | 2022-10-29T14:14:04.720Z [INFO]  Handle User | signin
    {"UserID":1,"Username":"netology","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NjcxMzkyNDQsInVzZXJfaWQiOjEsInVzZXJuYW1lIjoibmV0b2xvZ3kifQ.zT_ZGjdBBNGINvcOlxsHC6YFUifr02V7vSElAtCSVS4"}
    ```
- Сохраним токен в переменную окружения
    ```
    export HASHICUPS_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NjcxMzkyNDQsInVzZXJfaWQiOjEsInVzZXJuYW1lIjoibmV0b2xvZ3kifQ.zT_ZGjdBBNGINvcOlxsHC6YFUifr02V7vSElAtCSVS4
    ```
- Создадим манифест Terraform main.tf
    ```
    terraform {
      required_providers {
        hashicups = {
          version = "~> 0.3.1"
          source  = "hashicorp.com/edu/hashicups"
        }
      }
    }
    provider "hashicups" {
      username = "netology"
      password = "test123"
    }

    resource "hashicups_order" "edu" {
      items {
        coffee {
          id = 3
        }
        quantity = 2
      }
      items {
        coffee {
          id = 2
        }
        quantity = 2
      }
    }

    output "edu_order" {
      value = hashicups_order.edu
    }
    ```
- Инициализируем Terraform
    ```
    terraform init
    ```
- Применим изменения Terraform
    ```
    terraform apply
    ```
    ```
    Terraform will perform the following actions:

      # hashicups_order.edu will be created
      + resource "hashicups_order" "edu" {
          + id           = (known after apply)
          + last_updated = (known after apply)

          + items {
              + quantity = 2

              + coffee {
                  + description = (known after apply)
                  + id          = 3
                  + image       = (known after apply)
                  + name        = (known after apply)
                  + price       = (known after apply)
                  + teaser      = (known after apply)
                }
            }
          + items {
              + quantity = 2

              + coffee {
                  + description = (known after apply)
                  + id          = 2
                  + image       = (known after apply)
                  + name        = (known after apply)
                  + price       = (known after apply)
                  + teaser      = (known after apply)
                }
            }
        }

    Plan: 1 to add, 0 to change, 0 to destroy.

    Changes to Outputs:
      + edu_order = {
          + id           = (known after apply)
          + items        = [
              + {
                  + coffee   = [
                      + {
                          + description = (known after apply)
                          + id          = 3
                          + image       = (known after apply)
                          + name        = (known after apply)
                          + price       = (known after apply)
                          + teaser      = (known after apply)
                        },
                    ]
                  + quantity = 2
                },
              + {
                  + coffee   = [
                      + {
                          + description = (known after apply)
                          + id          = 2
                          + image       = (known after apply)
                          + name        = (known after apply)
                          + price       = (known after apply)
                          + teaser      = (known after apply)
                        },
                    ]
                  + quantity = 2
                },
            ]
          + last_updated = (known after apply)
        }
    ```
    ![07-terraform-06-01.png](07-terraform-06-01.png)  
- Проверим, что заказ создался
    ```
    curl -X GET  -H "Authorization: ${HASHICUPS_TOKEN}" localhost:19090/orders/1
    ```
    ```
    {"id":1,"items":[{"coffee":{"id":3,"name":"Nomadicano","teaser":"Drink one today and you will want to schedule another","description":"","price":150,"image":"/nomad.png","ingredients":null},"quantity":2},{"coffee":{"id":2,"name":"Vaulatte","teaser":"Nothing gives you a safe and secure feeling like a Vaulatte","description":"","price":200,"image":"/vault.png","ingredients":null},"quantity":2}]}
    ```

