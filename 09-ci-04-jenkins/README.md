# Домашнее задание к занятию "10.Jenkins"

## Подготовка к выполнению

1. Создать 2 VM: для jenkins-master и jenkins-agent.
2. Установить jenkins при помощи playbook'a.
3. Запустить и проверить работоспособность.
4. Сделать первоначальную настройку.

## Основная часть

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.
4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.
5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).
6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True), по умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.
7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`.
8. Отправить ссылку на репозиторий с ролью и Declarative Pipeline и Scripted Pipeline.

## Необязательная часть

1. Создать скрипт на groovy, который будет собирать все Job, которые завершились хотя бы раз неуспешно. Добавить скрипт в репозиторий с решением с названием `AllJobFailure.groovy`.
2. Создать Scripted Pipeline таким образом, чтобы он мог сначала запустить через Ya.Cloud CLI необходимое количество инстансов, прописать их в инвентори плейбука и после этого запускать плейбук. Тем самым, мы должны по нажатию кнопки получить готовую к использованию систему.

---

## Шаги:
- Устанавливаем `ansible`  
    ```
    apt install software-properties-common
    apt-add-repository ppa:ansible/ansible
    apt update
    apt install ansible
    ```
- Регистрируемся на Яндекс Облаке по адресу `console.cloud.yandex.ru`  
- Создаём платёжный аккаунт с промо-кодом  
- Скачаем и установим утилиту `yc`  
    - `curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash`  
- Запустим утилиту `yc`:    
    - `yc init`  
    - Получаем OAuth токен по адресу в браузере `https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb`  
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
- Получаем IAM-токен  
    ```
    yc iam create-token
    ```
- Сохраняем токен и параметры в переменную окружения  
    ```
    export YC_TOKEN=$(yc iam create-token)
    export YC_CLOUD_ID=$(yc config get cloud-id)
    export YC_FOLDER_ID=$(yc config get folder-id)
    export YC_ZONE=$(yc config get compute-default-zone)
    ```
- Сгенерируем SSH ключи на локальной машине  
    ```
    ssh-keygen
    ```
    ```
    Your public key has been saved in /root/.ssh/id_rsa.pub
    ```
- Создаём виртуальные машины в Яндекс Облаке
    - Укажем пользователя ansible при создании машины
    - Укажем публичный ключ при создании машины
    - jenkins-master: 51.250.67.116
    - jenkins-agent: 158.160.49.122
- Подключаемся к хостам, чтобы добавить SSH ключи в доверенные на локальной машине
    - ssh ansible@51.250.67.116
    - ssh ansible@158.160.49.122
- Пропишем в файле `infrastructure/inventory/cicd/hosts.yml` адреса машин и пользователя ansible
    ```
    ansible_host: 51.250.67.116
    ansible_host: 158.160.49.122
    ansible_user: ansible
    ``` 
- Запустим проигрывание в Ansible
    `ansible-playbook -i inventory/cicd/hosts.yml site.yml`
- Получи изначальный пароль для Jenkis с машины jenkins-master
    `ssh ansible@51.250.67.116 sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
- Открываем в браузере
    - jenkins-master: http://51.250.67.116:8080
        - Введём первоначальный пароль
        - Выбираем Install sugested plugins
        - создадим локального пользователя admin/1a6990aa636648e9b2ef855fa7bec2fb
        - Оставим Jenkins URL http://51.250.67.116:8080/
- Настроим агет
    - В меню Jenkins выберем Настроить Jenkins / Управление средами сборки 
    - Выберем в меню Новый узел 
        - Название узла: jenkins-agent
        - Тип: Permanent agent
    - В настройках агента укажем:
        - Number of executors; 2
        - Корень удалённой ФС: /opt/jenkins_agent/
        - Способ запуска: Launch agent via execution of command on the controller
        - Команда запуска: ssh 158.160.49.122 java -jar /opt/jenkins_agent/agent.jar
- Настроем мастер
    - В меню Jenkins выберем Настроить Jenkins / Управление средами сборки 
    - Выберем мастер
    - В меню выберем Настроить 
        - Количество процессов-исполнителей: 0
    - Dashboard > Настроить Jenkins > Глобальные настройки безопасности > Git Host Key Verification Configuration > No verification
    - Dashboard > Manage Credentials      
        - Создадим учётные данные нажав System > Global credentials > Add Credentials
            - SSH username with private key
            - ID: jenkins-master-ssh
            - Username: jenkins
            - Private key: указать закрытый ключ


- Добавим публичный ключ Jenkins в GitHub репозиторий
    - Получим публичные ключи
        - jenkins-master:
            - ssh ansible@51.250.67.116 sudo cat /home/jenkins/.ssh/id_rsa.pub

        - jenkins-agent:
            - ssh ansible@158.160.49.122 sudo cat /home/jenkins/.ssh/id_rsa.pub

    - Получим закрытые ключи
        - jenkins-master:
            - ssh ansible@51.250.67.116 sudo cat /home/jenkins/.ssh/id_rsa

        - jenkins-agent:
            - ssh ansible@158.160.49.122 sudo cat /home/jenkins/.ssh/id_rsa

    - В браузере откроем [SSH and GPG keys / Add SSH key|https://github.com/settings/ssh/new]

        - Username: jenkins
        - Private Key: закрытый ключ полученный ранее



- Создадим задачу Freestyle Job
    - В меню выберем Создать item 
        - имя: Freestyle Job
        - Создать задачу со свободной конфигурацией
    - Управление исходным кодом
        - Git
            - Repository URL: https://github.com/yuri-artemiev/devops-netology.git
    - Шаги сборки
        - Выполнить команду shell
            - ssh ansible@158.160.49.122
            - git clone https://github.com/yuri-artemiev/devops-netology.git

            - cd 08-ansible-05-testing/roles/vector
            # Потому что установлен только Docker
            - sed -i '/molecule_podman/d' tox-requirements.txt
            # Потому что выдаёт ошибку версии
            - sed -i '/ansible-lint/d' molecule/default/molecule.yml
            - pip3 install -r tox-requirements.txt
            - pip3 list
            - molecule test
            - docker ps
    - На странице проекта выберем в меню Собрать сейчас



- Создадим задачу Declarative Pipeline Job
    - В меню выберем Создать item 
        - имя: Declarative Pipeline Job
        - Definition: Pipeline script

pipeline{
    agent any
    stages{
        stage('Clear previous code'){
            steps{
                sh 'rm -rf devops-netology'
            }
        }
        stage('Git checkout'){
            steps{
                sh 'git clone https://github.com/yuri-artemiev/devops-netology.git'
            }
        }
        stage('Remove unneeded requirement'){
            steps{
                sh 'sed -i "/molecule_podman/d" devops-netology/08-ansible-05-testing/roles/vector/tox-requirements.txt'
            }
        }
        stage('Fixing test configuration'){
            steps{
                sh 'sed -i "/ansible-lint/d" devops-netology/08-ansible-05-testing/roles/vector/molecule/default/molecule.yml'
            }
        }
        stage('Install pip modules'){
            steps{
                sh 'pip3 install -r devops-netology/08-ansible-05-testing/roles/vector/tox-requirements.txt'
            }
        }
        stage('Run molecule test'){
            steps{
                sh 'cd devops-netology/08-ansible-05-testing/roles/vector && molecule test'
            }
        }
    }
}

    - На странице проекта выберем в меню Собрать сейчас




- Скопируем скрипт в файл `Jenkinsfile` и сохраним в репозиторий
- 




