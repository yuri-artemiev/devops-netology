# Домашнее задание к занятию "3.4. Операционные системы, лекция 2"

1. Создайте самостоятельно простой systemd unit-файл для `node_exporter`:  

Для начала установим node_exporter из архива:  
   ```
   wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
   tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz
   cd node_exporter-1.3.1.linux-amd64
   ./node_exporter
   ```
Создадим unit-файл и поместим туда созедржание  
   ```
   ```
...  
    * поместите его в автозагрузку,  
    ...  
    * предусмотрите возможность добавления опций к запускаемому процессу через внешний файл    
    ...  
    * удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.  
    ...  

1. Приведите несколько опций в /metrics, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.  
Проверим вывод митрик с помощью команды `curl http://localhost:9100/metrics`
```
# HELP go_gc_duration_seconds A summary of the pause duration of garbage collection cycles.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 0
go_gc_duration_seconds{quantile="0.25"} 0
go_gc_duration_seconds{quantile="0.5"} 0
go_gc_duration_seconds{quantile="0.75"} 0
go_gc_duration_seconds{quantile="1"} 0
go_gc_duration_seconds_sum 0
go_gc_duration_seconds_count 0
...
```

3. Установите в свою виртуальную машину `Netdata`  
...  
    * В браузере на своей машине зайдите на `localhost:19999`. Какие метрики по умолчанию собираются Netdata?  
...  
1. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?  
...  
3. Как настроен sysctl `fs.nr_open` на системе по-умолчанию?  
...   
    * Какой другой существующий лимит не позволит достичь такого числа?  
    ...  
4. Запустите любой долгоживущий процесс в отдельном неймспейсе процессов  
...  
    * покажите, что ваш процесс работает под PID 1 через `nsenter`  
    ...  
5. Найдите информацию о том, что такое `:(){ :|:& };:`  
...  
    * Какой механизм помог автоматической стабилизации, показан в `dmesg`  
    ...  
    * Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?  
    ...  