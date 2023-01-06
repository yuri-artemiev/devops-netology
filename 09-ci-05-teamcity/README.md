# Домашнее задание к занятию "11.Teamcity"

## Подготовка к выполнению

1. В Ya.Cloud создайте новый инстанс (4CPU4RAM) на основе образа `jetbrains/teamcity-server`
2. Дождитесь запуска teamcity, выполните первоначальную настройку
3. Создайте ещё один инстанс(2CPU4RAM) на основе образа `jetbrains/teamcity-agent`. Пропишите к нему переменную окружения `SERVER_URL: "http://<teamcity_url>:8111"`
4. Авторизуйте агент
5. Сделайте fork [репозитория](https://github.com/aragastmatb/example-teamcity)
6. Создать VM (2CPU4RAM) и запустить [playbook](./infrastructure)

## Основная часть

1. Создайте новый проект в teamcity на основе fork
2. Сделайте autodetect конфигурации
3. Сохраните необходимые шаги, запустите первую сборку master'a
4. Поменяйте условия сборки: если сборка по ветке `master`, то должен происходит `mvn clean deploy`, иначе `mvn clean test`
5. Для deploy будет необходимо загрузить [settings.xml](./teamcity/settings.xml) в набор конфигураций maven у teamcity, предварительно записав туда креды для подключения к nexus
6. В pom.xml необходимо поменять ссылки на репозиторий и nexus
7. Запустите сборку по master, убедитесь что всё прошло успешно, артефакт появился в nexus
8. Мигрируйте `build configuration` в репозиторий
9. Создайте отдельную ветку `feature/add_reply` в репозитории
10. Напишите новый метод для класса Welcomer: метод должен возвращать произвольную реплику, содержащую слово `hunter`
11. Дополните тест для нового метода на поиск слова `hunter` в новой реплике
12. Сделайте push всех изменений в новую ветку в репозиторий
13. Убедитесь что сборка самостоятельно запустилась, тесты прошли успешно
14. Внесите изменения из произвольной ветки `feature/add_reply` в `master` через `Merge`
15. Убедитесь, что нет собранного артефакта в сборке по ветке `master`
16. Настройте конфигурацию так, чтобы она собирала `.jar` в артефакты сборки
17. Проведите повторную сборку мастера, убедитесь, что сбора прошла успешно и артефакты собраны
18. Проверьте, что конфигурация в репозитории содержит все настройки конфигурации из teamcity
19. В ответ предоставьте ссылку на репозиторий

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
- Создаём контейнер в Яндекс Облаке
    - Укажем образ jetbrains/teamcity-server
    - Укажем пользователя ansible при создании машины
    - Укажем публичный ключ при создании машины
    - teamcity-server: 158.160.44.39
- Создаём контейнер в Яндекс Облаке
    - Укажем образ jetbrains/teamcity-agent
    - Укажем переменную окружения SERVER_URL: "http://158.160.44.39:8111"
    - Укажем пользователя ansible при создании машины
    - Укажем публичный ключ при создании машины
    - teamcity-agent: 51.250.77.177
- Создаём виртуальную машину в Яндекс Облаке
    - Укажем пользователя ansible при создании машины
    - Укажем публичный ключ при создании машины
    - nexus: 62.84.126.44
- Подключаемся к хостам, чтобы добавить SSH ключи в доверенные на локальной машине
    - teamcity-server: `ssh ansible@158.160.44.39`
    - teamcity-agent: `ssh ansible@51.250.77.177`
    - nexus: `ssh ansible@62.84.126.44`
- Пропишем в файле `infrastructure/inventory/cicd/hosts.yml` адреса машин и пользователя ansible
    ```
    ansible_host: 62.84.126.44
    ansible_user: ansible
    ``` 
- Запустим проигрывание в Ansible  
    - `ansible-playbook -i inventory/cicd/hosts.yml site.yml`
- Откроем в веб браузере панель управления Teamcity
    - http://158.160.44.39:8111
    - Выбираем использовать внутреннюю базу данных
    - Создаём пользователя admin / 1a6990aa636648e9b2ef855fa7bec2fb
    - Создадим проект нажава Create project / Manually
- Авторизуем агента Teamcity
    - В панели управление Teamcity Server выберем Agents / Unauthorized
    - Выберем агента и нажмём Authorize
- Создадим форк репозиторий
    - В веб бразуере откроем репозиторий https://github.com/aragastmatb/example-teamcity
    - Выберем Create a new fork
    - Оставим настройки по умолчанию
    - Нажмём Create fork
    - Адрес форка https://github.com/yuri-artemiev/example-teamcity
- Создадим доступ к репозиторию
    - На локальной машине сохраним приватный ключ /root/.ssh/id_rsa
    - Открываем панель управления Teamcity Server / Root project / SSH keys / Upload SSH key / выберем сохранённый приватный ключ
    - На локальной машине сохраним приватный ключ /root/.ssh/id_rsa.pub
    - В веб браузере откроем настройки GitHub аккаунта / SSH and GPG keys / New SSH key / Вставим публичный ключ в поле key
    - В веб браузере форка репозитория нажмём Code / SSH / Copy URL
        - git@github.com:yuri-artemiev/example-teamcity.git
- Создадим build конфигурацию
    - В панели управления Teamcity Server выберем созданный проект
    - В настройках проекта выберем New build configuration / From repository
        - Repository URL: git@github.com:yuri-artemiev/example-teamcity.git
        - Username: git
        - Token: публичный ключ
    - Подождём завершение сканирования репозитория
    - Выберем Build step: Maven
- 
