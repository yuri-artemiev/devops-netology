# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.


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
    `docker run --name postgres-06-db-04 -itd -v "${PWD}"/data:/var/lib/postgresql/data -v "${PWD}"/backup:/backup -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres:13`

Подключитесь к БД PostgreSQL используя `psql`.

- Подключимся к контейнеру и системе PostgreSQL  
    ```
    docker exec -it postgres-06-db-04 bash
    psql -U postgres
    ```

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
    - `\l`

- подключения к БД
    - `\c DBNAME`


- вывода списка таблиц
    - `\dt`


- вывода описания содержимого таблиц
    - `\d TABLENAME`


- выхода из psql
    - `\q`



## Задача 2

Используя `psql` создайте БД `test_database`.
`CREATE DATABASE test_database;`

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.
- Скопируем файл бэкапа в volume контейнера  
    - `cp /vagrant/06-db-04/test_dump.sql backup/test_dump.sql`
- Подключимся к контейнеру и системе PostgreSQL  
    - `docker exec -it postgres-06-db-04 bash`
- Восстановим резервную копию из файла  
    - `psql -U postgres -d test_database -f /backup/test_dump.sql`


Перейдите в управляющую консоль `psql` внутри контейнера.
```
docker exec -it postgres-06-db-04 bash
psql -U postgres
```

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
```
\c test_database
ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.
```
SELECT tablename, attname, avg_width FROM pg_stats WHERE tablename = 'orders' ORDER BY avg_width DESC LIMIT 1;
 tablename | attname | avg_width
-----------+---------+-----------
 orders    | title   |        16
```


## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Для проведения шардинга:  
- Переименовываем таблицу `orders` в `orders_old`  
- Создаём таблицу `orders` с типом `partitioned table`  
- Создаём две партитиции, связанные с таблицей `orders`  
- Вставляем содержимое из таблицы `orders_old` в таблицу `orders`  

```
BEGIN;
ALTER TABLE orders RENAME TO orders_old;

CREATE TABLE orders (
	id serial4 NOT NULL,
	title varchar(80) NOT NULL,
	price int4 NULL DEFAULT 0
) PARTITION BY RANGE (price);

CREATE TABLE orders_1 PARTITION OF orders FOR VALUES FROM (499) TO (MAXVALUE);

CREATE TABLE orders_2 PARTITION OF orders FOR VALUES FROM (0) TO (499);

INSERT INTO orders (SELECT * FROM orders_old);

DROP TABLE orders_old;
COMMIT;
```


Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

- Да, можно было бы создать таблицу типа `partitioned table` используя оператор `PARTITION BY RANGE (price)` и связать с ней партиции.  

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?
