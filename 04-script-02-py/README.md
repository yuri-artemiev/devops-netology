# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | ошибка в команде `c = a + b` потому что нельзя  использовать операцию `+` для числа и строки |
| Как получить для переменной `c` значение 12?  | преобразовать `a` в строку: `c = str(a) + b`  |
| Как получить для переменной `c` значение 3?  | преобразовать `b` в число: `c = a + int(b)`  |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os

# Переменная каталога для репозитория
dir = "~/netology/sysadm-homeworks/"
bash_command = [f"cd {dir}", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        # переменная для каталога + файла
        filepath = f"{dir}{prepare_result}"
        print(filepath)
        # продолжить цикл
        continue
```

### Вывод скрипта при запуске при тестировании:
```
~/netology/sysadm-homeworks/test-file3.txt
~/netology/sysadm-homeworks/test-folder/test-file5.txt
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import sys

try:
    dir = sys.argv[1]
except:
    print("Please enter folder path as parameter")
    sys.exit()
if not os.path.isabs(dir):
    print ("Please provide absolute path to the folder")
    sys.exit()
if not os.path.isdir(dir):
    print ("Please provide path to existing folder")
    sys.exit()
# Команда возвращает true если директория часть репозитория
git_status_check = os.popen(f"cd {dir} ; git rev-parse --is-inside-work-tree 2> /dev/null").read()
git_status = git_status_check.split('\n')[0]
if git_status != "true":
    print ("Directory is not inside repository")
    sys.exit()
bash_command = [f"cd {dir}", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        filepath = f"{dir}{prepare_result}"
        print(filepath)
        continue
```

### Вывод скрипта при запуске при тестировании:
```
./script-pygit2.py ~/netology/
Directory is not inside repository
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import time

# Список сервисов
services = ["drive.google.com", "mail.google.com", "google.com"]

# Словарь с изначальными IP адресами
initial_ip = {}
for item in services:
    print("Getting initial service address "+item)
    service_addr = socket.gethostbyname(item)
    initial_ip[item] = service_addr

# Цикл на проверку IP адреса каждый 5 секунд
while True:
    for item in services:
        print("Checking service address "+item)
        service_addr = socket.gethostbyname(item)
        initial_service_addr = initial_ip[item]
        if service_addr != initial_service_addr:
            print("[ERROR] "+item+" IP mismatch: "+initial_service_addr + " " + service_addr)
    time.sleep(5)
```

### Вывод скрипта при запуске при тестировании:
```
Getting initial service address drive.google.com
Getting initial service address mail.google.com
Getting initial service address google.com
Checking service address drive.google.com
Checking service address mail.google.com
Checking service address google.com
...
[ERROR] drive.google.com IP mismatch: 10.99.99.99 173.194.73.194
```
