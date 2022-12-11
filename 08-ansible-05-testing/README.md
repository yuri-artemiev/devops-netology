# Домашнее задание к занятию "5. Тестирование roles"

## Подготовка к выполнению
1. Установите molecule: `pip3 install "molecule==3.5.2"`
2. Выполните `docker pull aragast/netology:latest` -  это образ с podman, tox и несколькими пайтонами (3.7 и 3.9) внутри

## Основная часть

Наша основная цель - настроить тестирование наших ролей. Задача: сделать сценарии тестирования для vector. Ожидаемый результат: все сценарии успешно проходят тестирование ролей.

### Molecule

1. Запустите  `molecule test -s centos7` внутри корневой директории clickhouse-role, посмотрите на вывод команды.
2. Перейдите в каталог с ролью vector-role и создайте сценарий тестирования по умолчанию при помощи `molecule init scenario --driver-name docker`.
3. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.
4. Добавьте несколько assert'ов в verify.yml файл для  проверки работоспособности vector-role (проверка, что конфиг валидный, проверка успешности запуска, etc). Запустите тестирование роли повторно и проверьте, что оно прошло успешно.
5. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

### Tox

1. Добавьте в директорию с vector-role файлы из [директории](./tox)
2. Запустите `docker run --privileged=True -v <path_to_repo>:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash`, где path_to_repo - путь до корня репозитория с vector-role на вашей файловой системе.
3. Внутри контейнера выполните команду `tox`, посмотрите на вывод.
5. Создайте облегчённый сценарий для `molecule` с драйвером `molecule_podman`. Проверьте его на исполнимость.
6. Пропишите правильную команду в `tox.ini` для того чтобы запускался облегчённый сценарий.
8. Запустите команду `tox`. Убедитесь, что всё отработало успешно.
9. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

После выполнения у вас должно получится два сценария molecule и один tox.ini файл в репозитории. Ссылка на репозиторий являются ответами на домашнее задание. Не забудьте указать в ответе теги решений Tox и Molecule заданий.

## Необязательная часть

1. Проделайте схожие манипуляции для создания роли lighthouse.
2. Создайте сценарий внутри любой из своих ролей, который умеет поднимать весь стек при помощи всех ролей.
3. Убедитесь в работоспособности своего стека. Создайте отдельный verify.yml, который будет проверять работоспособность интеграции всех инструментов между ними.
4. Выложите свои roles в репозитории. В ответ приведите ссылки.

---


Шаги:
### Molecule
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
- Установим Molecule
    ```
    apt update
    apt install python3-pip
    pip3 install "molecule==3.5.2"
    pip3 install molecule_docker
    ```
- Скачаем образ контейнера
    ```
    docker pull aragast/netology:latest
    ```
- Создадим сценарии тестирования в роли `vector`
    ```
    cd playbook/roles/vector/
    molecule init scenario --driver-name docker
    ```
- Установим линтеры
    ```
    pip3 install ansible-lint
    pip3 install yamllint
    ```
- Отредактируем molecule/default/converge.yml
    ```
    ---
    - name: Converge
      hosts: all
      tasks:
        - name: "Include vector"
          include_role:
            name: "vector"
    ```
- Отредактируем molecule/default/molecule.yml
    ```
    ---
    dependency:
      name: galaxy
    driver:
      name: docker
    lint: |
      yamllint .
      ansible-lint .
    ...
    ```
- Отредактируем molecule/default/verify.yml
    ```
    ---
    # This is an example playbook to execute Ansible tests.
    - name: Verify
      hosts: all
      gather_facts: false
      tasks:
    ...
    ```
- Для выявления ошибок запустим последовательно команды molecue
    ```
    molecule create -s default
    molecule converge -s default
    molecule verify -s default
    molecule list
    molecule login --host vector-centos8
    molecule destroy
    ```
- Руководствуемся последовательностью шагов в molecule
    ```
    ---
    default:
      - dependency
      - lint
      - cleanup
      - destroy
      - syntax
      - create
      - prepare
      - converge
      - idempotence
      - side_effect
      - verify
      - cleanup
    ```
- Для исправления ошибок molecule, воспользуемся командами
    - Запуск контейнер из образа
        ```
        docker run --name tmp-centos8 -itd --privileged=true --cap-add=SYS_ADMIN --tmpfs /run --tmpfs /run/lock --tmpfs /tmp -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 2480:2480 quay.io/centos/centos:stream8 /usr/sbin/init
        ```
    - Подключение в терминал контейнера в docker
        ```
        docker exec -it --user root tmp-centos8 /bin/bash
        ```
    - Список запущенных площадок в molecule
        ```
        molecule list
        ```
        ```
          Instance Name       │ Driver Name │ Provisioner Name │ Scenario Name │ Created │ Converged
        ╶─────────────────────┼─────────────┼──────────────────┼───────────────┼─────────┼───────────╴
          vector-centos8      │ docker      │ ansible          │ default       │ true    │ true
          vector-ubuntu-22.04 │ docker      │ ansible          │ default       │ true    │ true

        ```
- Запустим полный тест molecule, после того как molecule будет проходить без ошибок
    ```
    molecule test
    ```


### Tox
3. Внутри контейнера выполните команду `tox`, посмотрите на вывод.
5. Создайте облегчённый сценарий для `molecule` с драйвером `molecule_podman`. Проверьте его на исполнимость.
6. Пропишите правильную команду в `tox.ini` для того чтобы запускался облегчённый сценарий.
8. Запустите команду `tox`. Убедитесь, что всё отработало успешно.
9. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.



- Скопируем файлы из репозитория в корень роли vector
    - tox.ini
    - tox-requirements.txt
- Отредактируем файл tox-requirements.txt
    ```
    selinux
    ansible-lint==5.1.3
    yamllint==1.26.3
    lxml
    molecule==3.4.0
    molecule_podman
    molecule_docker
    jmespath
    ```
- Скопируем сценарий molecule/default в сценарий molecule/compatibility 
    ```
    cp -r molecule/default molecule/compatibility 
    ```
- Отредактируем molecule.yml в сценарии compatibility
    ```
    driver:
      name: podman
    ```
- Отредактируем molecule/compatability/converge.yml
    ```
    ---
    - name: Converge
      hosts: all
      tasks:
        - name: "Include vector"
          include_role:
            name: "vector-role"
    ```
- Запустим команду
    ```
    docker run --name tox -it --privileged=true --cap-add=SYS_ADMIN --tmpfs /run --tmpfs /run/lock --tmpfs /tmp -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /vagrant/08-05/playbook/roles/vector:/opt/vector-role -w /opt/vector-role -p 2480:2480 aragast/netology:latest /bin/bash
    ```
- Очистим директории от старых пакетов в контейнере (исправляет баг с зависимостями)
    ```
    rm -rf /opt/vector-role/.tox/
    ```
- Запустим внутри контейнера окружение tox с чистого листа
    ```
    tox -r
    ```

























 

