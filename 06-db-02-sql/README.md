# Домашнее задание к занятию "6.2. SQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

- Установим Docker  
    ```
    apt-get install ca-certificates curl gnupg lsb-release
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    ```
- Запустим образ PostgreSQL  
    `docker run --name postgres -itd -v "${PWD}"/data:/var/lib/postgresql/data -v "${PWD}"/backup:/backup -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres:12`

    



## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db  
    - Подключимся к контейнеру и Postgresql  
        ```
        docker exec -it postgres bash
        psql -U postgres
        ```
    - Создадим пользователя `test-admin-user`  
        `CREATE USER "test-admin-user" WITH LOGIN;`
    - Создадим базу данных `test_db`  
        `CREATE DATABASE test_db;`  
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)  
    ```
    CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    name TEXT,
    price INT
    );
    ```
    ```
    CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    lastname TEXT,
    country TEXT,
    order_id INT,
    FOREIGN KEY (order_id) REFERENCES orders(id)
    );
    ```
- предоставьте привилегии на все операции пользователю `test-admin-user` на таблицы БД `test_db`  
    `GRANT ALL ON TABLE clients, orders TO "test-admin-user";`
- создайте пользователя `test-simple-user`  
    `CREATE USER "test-simple-user" WITH LOGIN;`
- предоставьте пользователю `test-simple-user` права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД `test_db`  
    `GRANT SELECT,INSERT,UPDATE,DELETE ON TABLE clients,orders TO "test-simple-user";`

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
    ```
    \l
                                         List of databases
       Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
    -----------+----------+----------+------------+------------+-----------------------
     postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
     template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
               |          |          |            |            | postgres=CTc/postgres
     template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
               |          |          |            |            | postgres=CTc/postgres
     test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
    ```
- описание таблиц (describe)
    ```
    \d+ orders
                                                        Table "public.orders"
     Column |  Type   | Collation | Nullable |              Default               | Storage  | Stats target | Description
    --------+---------+-----------+----------+------------------------------------+----------+--------------+-------------
     id     | integer |           | not null | nextval('orders_id_seq'::regclass) | plain    |              |
     name   | text    |           |          |                                    | extended |              |
     price  | integer |           |          |                                    | plain    |              |
    Indexes:
        "orders_pkey" PRIMARY KEY, btree (id)
    Referenced by:
        TABLE "clients" CONSTRAINT "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)
    Access method: heap
    
    \d+ clients
                                                         Table "public.clients"
      Column  |  Type   | Collation | Nullable |               Default               | Storage  | Stats target | Description

    ----------+---------+-----------+----------+-------------------------------------+----------+--------------+------------
    -
     id       | integer |           | not null | nextval('clients_id_seq'::regclass) | plain    |              |
     lastname | text    |           |          |                                     | extended |              |
     country  | text    |           |          |                                     | extended |              |
     order_id | integer |           |          |                                     | plain    |              |
    Indexes:
        "clients_pkey" PRIMARY KEY, btree (id)
    Foreign-key constraints:
        "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)
    Access method: heap
    ```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
    ```
    SELECT table_name, array_agg(privilege_type), grantee
    FROM information_schema.table_privileges
    WHERE table_name = 'orders' OR table_name = 'clients'
    GROUP BY table_name, grantee ;
    ```
- список пользователей с правами над таблицами test_db
    ```
    table_name |                         array_agg                         |     grantee
    ------------+-----------------------------------------------------------+------------------
     clients    | {INSERT,TRIGGER,REFERENCES,TRUNCATE,DELETE,UPDATE,SELECT} | postgres
     clients    | {INSERT,TRIGGER,REFERENCES,TRUNCATE,DELETE,UPDATE,SELECT} | test-admin-user
     clients    | {DELETE,INSERT,SELECT,UPDATE}                             | test-simple-user
     orders     | {INSERT,TRIGGER,REFERENCES,TRUNCATE,DELETE,UPDATE,SELECT} | postgres
     orders     | {INSERT,TRIGGER,REFERENCES,TRUNCATE,DELETE,UPDATE,SELECT} | test-admin-user
     orders     | {DELETE,SELECT,UPDATE,INSERT}                             | test-simple-user
    ```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

- Запрос
    ```
    INSERT INTO orders (name, price) VALUES
    ('Шоколад', '10'),
    ('Принтер', '3000'),
    ('Книга', '500'),
    ('Монитор', '7000'),
    ('Гитара', '4000')
    ;
    ```

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

- Запрос SQL
    ```
    INSERT INTO clients (lastname, country) VALUES 
    ('Иванов Иван Иванович', 'USA'),
    ('Петров Петр Петрович', 'Canada'),
    ('Иоганн Себастьян Бах', 'Japan'),
    ('Ронни Джеймс Дио', 'Russia'),
    ('Ritchie Blackmore', 'Russia')
    ;
    ```

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
    ```
    SELECT COUNT(*) FROM orders;
     count
    -------
        5
        
    SELECT COUNT(*) FROM clients;
     count
    -------
        5
    ```



## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

- Запрос SQL
    ```
    UPDATE clients
    SET order_id = (SELECT id FROM orders WHERE name = 'Книга')
    WHERE lastname = 'Иванов Иван Иванович';

    UPDATE clients
    SET order_id = (SELECT id FROM orders WHERE name = 'Монитор')
    WHERE lastname = 'Петров Петр Петрович';

    UPDATE clients
    SET order_id = (SELECT id FROM orders WHERE name = 'Гитара')
    WHERE lastname = 'Иоганн Себастьян Бах';
    ```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 


## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 
