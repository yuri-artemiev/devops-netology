# Домашнее задание к занятию "1. Введение в Ansible"

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

Шаги:
- Устанавливаем утилиту `ansible`  
    ```
    apt install software-properties-common
    apt-add-repository ppa:ansible/ansible
    apt update
    apt install ansible
    ```
    

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.
    - Запустим playbook
        ```
        ansible-playbook -i inventory/test.yml site.yml
        ```
    - Значение факта `some_fact`
        ```
        "msg": 12
        ```
2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.
    - Факт задаётся в файле `./group_vars/all/examp.yml`
    - Изменим значение факта `some_fact` в файле `./group_vars/all/examp.yml`
    - Запустим playbook
        ```
        ansible-playbook -i inventory/test.yml site.yml
        ```
    - Значение факта `some_fact`
        ```
        "msg": "all default fact"
        ```
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
    - Установим Docker  
        ```
        apt-get install ca-certificates curl gnupg lsb-release
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update
        apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
        ```
    - Запустим контейнеры из образов  
        ```
        docker run --name centos7 -itd centos:7
        docker run --name ubuntu -itd ubuntu:latest
        ```
    - Добавим Python на контейнер Ubuntu
        ```
        docker exec -it --user root 62ff0af1e073 /bin/bash
        apt-get update
        apt-get install --no-install-recommends -y python3
        ```
5. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
    - Запустим playbook
        ```
        ansible-playbook -i inventory/prod.yml site.yml
        ```
    - Значение факта `some_fact`
        ```
        TASK [Print fact] 
        ok: [centos7] => {
            "msg": "el"
        }
        ok: [ubuntu] => {
            "msg": "deb"
        }
        ```
7. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.
    - Факт Ubuntu контейнера задаётся в файле `./group_vars/deb/examp.yml`
    - Изменим значение факта `some_fact` в файле `./group_vars/deb/examp.yml`
    - Факт Centos контейнера задаётся в файле `./group_vars/el/examp.yml`
    - Изменим значение факта `some_fact` в файле `./group_vars/el/examp.yml`
9.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
    - Запустим playbook
        ```
        ansible-playbook -i inventory/prod.yml site.yml
        ```
    - Значение факта `some_fact`
        ```
        TASK [Print fact] 
        ok: [centos7] => {
            "msg": "el default fact"
        }
        ok: [ubuntu] => {
            "msg": "deb default fact"
        }
        ```
11. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
12. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
13. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
14. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
15. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
16. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

