# Домашнее задание к занятию "3. Использование Yandex Cloud"

## Подготовка к выполнению

1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.

Ссылка на репозиторий LightHouse: https://github.com/VKCOM/lighthouse

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику lighthouse, установить nginx или любой другой webserver, настроить его конфиг для открытия lighthouse, запустить webserver.
4. Приготовьте свой собственный inventory файл `prod.yml`.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

---


Шаги:
- Устанавливаем утилиту `ansible`  
    ```
    apt install software-properties-common
    apt-add-repository ppa:ansible/ansible
    apt update
    apt install ansible
    ```
- Установим Docker  
    ```
    apt-get install ca-certificates curl gnupg lsb-release
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    ```
- Устанавливаем yc
- Подключаемся к яндекс облаку с помощью yc cli
- Создать виртуальные машины в яндекс облаке с помощью yc
    Может быть использовать Anaible
    ```
    - name: Create VM in Yandex cloud
      delegate_to: 127.0.0.1
      ansible.builtin.command: "/usr/bin/yc create vm --name {{ item }} --public-key"
      with_items:
        - clickhouse-01
        - vector-01
        - lighthouse-01
      register: newnodes
    ```
- Создать внутренний файл inventory
    ```
    - name: Create in-memory Ansible inventory
      add_host:
        name: "{{ item.server.public_v4 }}"
        groups: created_nodes
        ansible_user: ubuntu
        instance_name: "{{ item.server.name }}"
      loop: "{{ newnodes.results }}"
    ```



### Clickhouse  
- Отредактируем файл `playbook/inventory/prod.yml`
    ```
    ---
    clickhouse:
      hosts:
        clickhouse-01:
          ansible_connection: docker
    ```
- Отредактируем файл `playbook/group_vars/clickhouse.yml`
    ```
    ---
    clickhouse_packages:
      - clickhouse-common-static-22.9.4.32.x86_64.rpm
      - clickhouse-server-22.9.4.32.x86_64.rpm
      - clickhouse-client-22.9.4.32.x86_64.rpm
    ```
- Отредактируем файл `playbook/templates/config.xml.j2`
- Запустим контейнер из образа
    ```
    docker run --name clickhouse-01 -itd -p 8123:8123 --privileged=true centos:7 /usr/sbin/init
    ```
- Запустим playbook
    ```
    ansible-playbook -i inventory/prod.yml site.yml
    ```
- Зайдём в docker конейнер
    ```
    docker exec -it --user root caa457848a6f /bin/bash
    ```
- Проверим установленные RPM пакеты
    ```
    rpm -qa | grep clickhouse
    ```
- Проверим установленный systemd сервис
    ```
    systemctl list-unit-files | grep clickhouse
    ```
- Проверим статус запущенного systemd сервиса
    ```
    systemctl status clickhouse-server
    ```
- Проверим слущащий порт
    ```
    ss -tlpn | grep 8123
    ```
- Проверим подключение
    ```
    curl localhost:8123
    ```

### Vector  
- Отредактируем файл `playbook/inventory/prod.yml`
    ```
    ---
    clickhouse:
      hosts:
        clickhouse-01:
          ansible_connection: docker
    vector:
      hosts:
        vector-01:
          ansible_connection: docker
    ```
- Отредактируем файл `playbook/group_vars/vector.yml
    ```
    ---
    vector_packages:
      - vector-0.25.1-1.x86_64.rpm
    ```
- Отредактируем файл `playbook/templates/vector.toml.j2`
- Запустим контейнер из образа
    ```
    docker run --name vector-01 -itd --privileged=true almalinux:8 /usr/sbin/init
    ```
- Запустим playbook
    ```
    ansible-playbook -i inventory/prod.yml site.yml
    ```
- Зайдём в docker конейнер
    ```
    docker exec -it --user root 8a4cee6f8c22 /bin/bash
    ```
- Проверим установленные RPM пакеты
    ```
    rpm -qa | grep vector
    ```
- Проверим установленный systemd сервис
    ```
    systemctl list-unit-files | grep vector
    ```
- Проверим статус запущенного systemd сервиса
    ```
    systemctl status vector
    ```
- Проверим логи в базе Clickhouse на веб `http://192.168.1.118:8123/play`
    ```
    SELECT * FROM logs.demo_logs;
    ```
    ![08-ansible-02.png](08-ansible-02.png)