# Домашнее задание к занятию "5.4. Оркестрация группой Docker контейнеров на примере Docker Compose"

## Задача 1

Создать собственный образ операционной системы с помощью Packer.

Для получения зачета, вам необходимо предоставить:
- Скриншот страницы, как на слайде из презентации (слайд 37).

Шаги:  
- Регистрация на Яндекс Облаке console.cloud.yandex.ru  
- Создать платёжный аккаунт с промо-кодом  
- Скачать и установить утилиту `yc`  
    - `curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash`  
- Запустить первый запуск `yc`  
    - `cd src/`  
    - `yc init`  
    - Получить OAuth токен по адресу в браузере `https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb`  
    - В утилите `yc`    
        - Вставить токен  
        - Выбрать папку в Яндекс Облаке  
        - Выбрать создания Compute по-умолчанию  
        - Выбрать зону в Яндекс Облаке  
    - Проверим созданные настройки  
        - `yc config list`
            ```
            token: y0_A...
            cloud-id: b1gjd8gta6ntpckrp97r
            folder-id: b1gcthk9ak11bmpnbo7d
            compute-default-zone: ru-central1-a
            ```
    - Создаём сеть в Яндекс облаке    
        - `yc vpc network create --name net --labels my-label=netology --description "my first network via yc"`  
            ```
            id: enp7b44svg1838v53jrp
            folder_id: b1gcthk9ak11bmpnbo7d
            created_at: "2022-09-04T13:12:07Z"
            name: net
            description: my first network via yc
            labels:
            my-label: netology
            ```
    - ``  
    - ``  
    - ``  
    - ``  



## Задача 2

Создать вашу первую виртуальную машину в Яндекс.Облаке.

Для получения зачета, вам необходимо предоставить:
- Скриншот страницы свойств созданной ВМ, как на примере ниже:


## Задача 3

Создать ваш первый готовый к боевой эксплуатации компонент мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить:
- Скриншот работающего веб-интерфейса Grafana с текущими метриками, как на примере ниже


Удалить использованные ресурсы
    terraform destroy
    yc delete
