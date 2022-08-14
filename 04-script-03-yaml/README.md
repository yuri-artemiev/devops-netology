# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис  
### Исправленая версия  
```
{ "info" : "Sample JSON output from our service\t",
    "elements" :[
        { "name" : "first",
        "type" : "server",
        "ip" : "7175"
        },
        { "name" : "second",
        "type" : "proxy",
        "ip" : "71.78.22.43"
        }
    ]
}
```

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт для JSON:
```python
#!/usr/bin/env python3

import socket
import time
import json

services = ["drive.google.com", "mail.google.com", "google.com"]

initial_ip = {}
for item in services:
    print("Getting initial service address "+item)
    service_addr = socket.gethostbyname(item)
    initial_ip[item] = service_addr

with open('services.json', 'w') as services_json:
    print("Writing to init file")
    json.dump(initial_ip, services_json)

while True:
    print("Opening file init")
    is_changed = False
    with open('services.json', 'r') as services_json:
        services_object = json.load(services_json)
    for item in services:
        print("..Checking service address "+item)
        service_addr = socket.gethostbyname(item)
        initial_service_addr = services_object[item]
        if service_addr != initial_service_addr:
            print("[ERROR] "+item+" IP mismatch: "+initial_service_addr + " " + service_addr)
            services_object[item] = service_addr
            is_changed = True
    if is_changed:
        with open('services.json','w') as services_json:
            print("Writing new data to file")
            json.dump(services_object, services_json)
            is_changed = False
    time.sleep(10)

```

### Вывод скрипта для JSON при запуске при тестировании:
```
Getting initial service address drive.google.com
Getting initial service address mail.google.com
Getting initial service address google.com
Writing to init file
...
..Checking service address drive.google.com
[ERROR] drive.google.com IP mismatch: 173.194.73.194 10.10.10.10
..Checking service address mail.google.com
..Checking service address google.com
Writing new data to file
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{"drive.google.com": "173.194.73.194", "mail.google.com": "173.194.222.17", "google.com": "74.125.131.102"}
```
### json-файл, после изменения ip адреса:
```json
{"drive.google.com": "10.10.10.10", "mail.google.com": "173.194.222.17", "google.com": "74.125.131.102"}
```



### Ваш скрипт для YAML:
```python
#!/usr/bin/env python3

import socket
import time
import yaml

services = ["drive.google.com", "mail.google.com", "google.com"]

initial_ip = {}
for item in services:
    print("..Getting initial service address "+item)
    service_addr = socket.gethostbyname(item)
    initial_ip[item] = service_addr

with open('services.yml', 'w') as services_yaml:
    print("Writing to init file")
    yaml.dump(initial_ip, services_yaml)


while True:
    print("Opening file init")
    is_changed = False
    with open('services.yml', 'r') as services_yaml:
        services_object = yaml.load(services_yaml)
    for item in services:
        print("..Checking service address "+item)
        service_addr = socket.gethostbyname(item)
        initial_service_addr = services_object[item]
        if service_addr != initial_service_addr:
            print("[ERROR] "+item+" IP mismatch: "+initial_service_addr + " " + service_addr)
            services_object[item] = service_addr
            is_changed = True
    if is_changed:
        with open('services.yml','w') as services_yaml:
            print("Writing new data to file")
            yaml.dump(services_object, services_yaml)
            is_changed = False
    time.sleep(10)
```

### Вывод скрипта для YAML при запуске при тестировании:
```
..Getting initial service address drive.google.com
..Getting initial service address mail.google.com
..Getting initial service address google.com
Writing to file
...
..Checking service address drive.google.com
[ERROR] drive.google.com IP mismatch: 173.194.73.194 10.10.10.10
Writing to file
```


### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
drive.google.com: 173.194.73.194
google.com: 74.125.131.101
mail.google.com: 173.194.222.83
```
### yml-файл, после изменения ip адреса:
```yaml
drive.google.com: 10.10.10.10
google.com: 74.125.131.101
mail.google.com: 173.194.222.83
```
