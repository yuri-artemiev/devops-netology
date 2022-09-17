# Домашнее задание к занятию "6.3. MySQL"


## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.  

- Установим Docker  
    ```
    apt-get install ca-certificates curl gnupg lsb-release
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    ```
- Создадим папки в текущей директории
    ```
    mkdir data
    mkdir backup
    ```
- Запустим образ PostgreSQL  
    `docker run --name mysql -itd -v "${PWD}"/data:/var/lib/mysql -v "${PWD}"/backup:/backup -p 3306:3306 -e MYSQL_ROOT_PASSWORD=mysql mysql:8`







Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.  
- Резервная копия содержит таблицу `orders` и заполняет её данными.  
- Подключимся к контейнеру и системе MySQL  
    `docker exec -it mysql bash`
- Создадим пустую базу данный `test_db`  
    `mysql -u root -p -e "create database test_db"`
- Восстановим базу данных `test_db` из резервной копии  
    `mysql -u root -p test_db < backup/test_dump.sql`
    

Перейдите в управляющую консоль `mysql` внутри контейнера.  
- Подлючимся к системе MySQL  
    `mysql -u root -p`  

Используя команду `\h` получите список управляющих команд.  
Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.  
- Выведем статус подключения  
    ```
    mysql> \s
    --------------
    mysql  Ver 8.0.30 for Linux on x86_64 (MySQL Community Server - GPL)

    Connection id:          13
    Current database:       mysql
    Current user:           root@localhost
    ```

Подключитесь к восстановленной БД и получите список таблиц из этой БД.  
- Подключимся к базе данных `test_db` и вывидим список таблиц  
    ```
    mysql> \r test_db
    Connection id:    15
    Current database: test_db
    mysql> SHOW TABLES;
    +-------------------+
    | Tables_in_test_db |
    +-------------------+
    | orders            |
    +-------------------+
    ```


**Приведите в ответе** количество записей с `price` > 300.  
- Запрос SQL  
    ```
    SELECT COUNT(*) FROM orders WHERE price > 300;
    +----------+
    | COUNT(*) |
    +----------+
    |        1 |
    +----------+
    ```

В следующих заданиях мы будем продолжать работу с данным контейнером.

  


## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

- Запрос SQL на создание пользователя   
    ```
    CREATE USER 'test'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test-pass' 
    WITH MAX_QUERIES_PER_HOUR 100 PASSWORD EXPIRE INTERVAL 180 DAY 
    FAILED_LOGIN_ATTEMPTS 3 ATTRIBUTE '{"fname": "James", "lname": "Pretty"}';
    ```

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
- Запрос SQL на предоставление привелегий  
    `GRANT SELECT ON test_db.* TO 'test'@'localhost';`
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и  **приведите в ответе к задаче**.  
- Запрос SQL
    ```
    mysql> SELECT * FROM information_schema.user_attributes WHERE user='test';
    +------+-----------+---------------------------------------+
    | USER | HOST      | ATTRIBUTE                             |
    +------+-----------+---------------------------------------+
    | test | localhost | {"fname": "James", "lname": "Pretty"} |
    +------+-----------+---------------------------------------+
    ```


  

  



## Задача 3

Установите профилирование `SET profiling = 1`.  
Изучите вывод профилирования команд `SHOW PROFILES;`.  
- Запрос SQL  
    ```
    mysql> SET profiling = 1;
    mysql> SHOW profiles;
    +----------+------------+--------------------------------------------------------------------+
    | Query_ID | Duration   | Query                                                              |
    +----------+------------+--------------------------------------------------------------------+
    |        1 | 0.00004300 | SHOW profiles                                                      |
    |        2 | 0.00031800 | SELECT * FROM information_schema.user_attributes WHERE user='test' |
    +----------+------------+--------------------------------------------------------------------+
    ```

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.  
- Запрос SQL  
```
mysql> SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'test_db';
+------------+--------+
| TABLE_NAME | ENGINE |
+------------+--------+
| orders     | InnoDB |
+------------+--------+
```

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:  
- на `MyISAM`
    - Запрос SQL  
        ```
        mysql> ALTER TABLE orders ENGINE = myisam;
        Query OK, 5 rows affected (0.06 sec)
        ```
- на `InnoDB`
    - Запрос SQL  
        ```
        mysql> ALTER TABLE orders ENGINE = innodb;
        Query OK, 5 rows affected (0.07 sec)
        ```

- Показать список профайлера  
    ```
    mysql> SHOW profiles;
    +----------+------------+-------------------------------------+
    | Query_ID | Duration   | Query                               |
    +----------+------------+-------------------------------------+
    | ...      |            |                                     |
    |        4 | 0.05384500 | ALTER TABLE orders ENGINE = myisam  |
    |        5 | 0.07100325 | ALTER TABLE orders ENGINE = innodb  |
    +----------+------------+-------------------------------------+
    ```
  



## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

- Чтобы отредактировать файл `my.cnf` воспользуемся копированием  
    - Из контейнера в локальную папку  
        `docker container cp mysql:/etc/my.cnf container-my.cnf`
    - Отредактируем файл  
        ```
        [mysqld]
        ...
        innodb_buffer_pool_size=1G
        innodb_log_file_size=100M
        innodb_log_buffer_size=1М
        innodb_file_per_table = ON
        innodb_flush_method = O_DSYNC
        ```
    - Копируем локальный файл обратно в контейнер  
        `docker container cp container-my.cnf mysql:/etc/my.cnf`


  



