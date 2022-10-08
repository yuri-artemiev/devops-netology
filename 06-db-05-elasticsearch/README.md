# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [elasticsearch:7](https://hub.docker.com/_/elasticsearch) как базовый:

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib` 
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения
- обратите внимание на настройки безопасности такие как `xpack.security.enabled` 
- если докер образ не запускается и падает с ошибкой 137 в этом случае может помочь настройка `-e ES_HEAP_SIZE`
- при настройке `path` возможно потребуется настройка прав доступа на директорию

Далее мы будем работать с данным экземпляром elasticsearch.


- Установим Docker  
    ```
    apt-get install ca-certificates curl gnupg lsb-release
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    ```
- Создадим папку для volume  
    ```
    mkdir -p ~/06-db-05/docker/elasticsearch/data
    chmod -R 777 ~/06-db-05/docker/elasticsearch
    ```

- Запустим контейнер `elasticsearch` чтобы достать файл конфигурации `elasticsearch.yml`
    ```
    docker pull docker.elastic.co/elasticsearch/elasticsearch:7.17.6
    docker run -itd --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.17.6
    docker container cp elasticsearch:/usr/share/elasticsearch/config/elasticsearch.yml ~/06-db-05/docker/container-elasticsearch.yml
    docker stop elasticsearch
    ```

- Отредактируем файл конфигурации на локально хосте  
    ```
    nano ~/06-db-05/docker/container-elasticsearch.yml
    ```
    ```
    cluster.name: "netology_test"
    path.data: /var/lib/elasticsearch/data
    network.host: 0.0.0.0
    ```

- Создадим и отредатируем `Dokcerfile`  
    ```
    nano ~/06-db-05/docker/Dockerfile
    ```
    ```
    FROM docker.elastic.co/elasticsearch/elasticsearch:7.17.6
    COPY --chown=elasticsearch:elasticsearch ./container-elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
    RUN mkdir -p /var/lib/elasticsearch/data
    RUN chmod -R 777 /var/lib/elasticsearch
    RUN chown -R 1000:0 /var/lib/elasticsearch
    ```



- Убедимся что текущей папке существуют два файла
    ```
    ls ~/06-db-05/docker
    container-elasticsearch.yml  Dockerfile  elasticsearch
    ```



- Запустим сборку обаза с тегом `yuriartemiev/elasticsearch:local` в текущей директории `.`  
    ```
    docker build -t yuriartemiev/elasticsearch:local .
    ```
    ```
    Sending build context to Docker daemon  4.096kB
    Step 1/4 : FROM docker.elastic.co/elasticsearch/elasticsearch:7.17.6
     ---> 5fad10241ffd
    Step 2/4 : COPY --chown=elasticsearch:elasticsearch ./container-elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
     ---> b94fa41a96d7
    ...
    Successfully built a0fdc9741473
    Successfully tagged yuriartemiev/elasticsearch:local
    ```
- Проверим что обаз создался
    ```
    docker images
    REPOSITORY                  TAG     IMAGE ID       CREATED              SIZE
    yuriartemiev/elasticsearch  local   a0fdc9741473   About a minute ago   606MB
    ```
- Запустим контейнер чтобы проверить, что xxx. Название контейнера: `elasticsearch`, опубликовать порты `9200`, `9300`.
    ```
    docker run -itd --name elasticsearch-custom -v "${PWD}"/elasticsearch/data:/var/lib/elasticsearch/data -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" yuriartemiev/elasticsearch:local
    ```

- Проверим выдачу с хост системы  
    ```
    curl 192.168.1.116:9200/
    {
      "name" : "df918fe7ab4d",
      "cluster_name" : "netology_test",
      "cluster_uuid" : "yXG2e3DPTdG2qB7CU_CCJA",
      "version" : {
        "number" : "7.17.6",
        "build_flavor" : "default",
        "build_type" : "docker",
        "build_hash" : "f65e9d338dc1d07b642e14a27f338990148ee5b6",
        "build_date" : "2022-08-23T11:08:48.893373482Z",
        "build_snapshot" : false,
        "lucene_version" : "8.11.1",
        "minimum_wire_compatibility_version" : "6.8.0",
        "minimum_index_compatibility_version" : "6.0.0-beta1"
      },
      "tagline" : "You Know, for Search"
    }
    ```




- Назначим тег образу
    ```
    docker tag a0fdc9741473 yuriartemiev/elasticsearch:netology
    ```
- Подключаемся к Docker Hub
    ```
    docker login -u yuriartemiev
    ```
- Отправим образ в репозиторий
    ```
    docker push yuriartemiev/elasticsearch:netology
    ```
https://hub.docker.com/r/yuriartemiev/elasticsearch








docker container cp elasticsearch-custom:/etc/hostname container-hostname

Likely root cause: java.nio.file.AccessDeniedException: /var/lib/elasticsearch/data/nodes
For complete error details, refer to the log at /usr/share/elasticsearch/logs/netology_test.log

`curl 'localhost:9200/_cat/health?v'`


docker exec -it elasticsearch bash
pwd
    /usr/share/elasticsearch
drwxrwxr-x 1 root root 4096 Oct  8 12:02 /usr/share/elasticsearch/
-rw-rw-r-- 1 root root 53 Aug 23 15:07 /usr/share/elasticsearch/config/elasticsearch.yml
drwxrwxr-x 1 elasticsearch root 4096 Oct  8 12:02 /usr/share/elasticsearch/data/
Ctrl+D
curl 192.168.1.116:9200/_cat/health







## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.






## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.


- Создадим папку 
    ```
    mkdir -p ~/06-db-05/docker/elasticsearch/snapshots
    chmod -R 777 ~/06-db-05/docker/elasticsearch
    ```


Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`  


