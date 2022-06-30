# Домашнее задание к занятию "3.4. Операционные системы, лекция 2"

1. Создайте самостоятельно простой systemd unit-файл для `node_exporter`:  

    Для начала установим node_exporter из архива:  
    ```
    wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
    tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz
    cd node_exporter-1.3.1.linux-amd64
    cp node_exporter /usr/local/bin
    ```
    
    Создадим unit-файл `/etc/systemd/system/node_exporter.service` и поместим туда созедржание  
    ```
    [Unit]
    Description=Node Exporter
    Wants=network-online.target
    After=network.target

    [Service]
    User=node_exporter
    Group=node_exporter
    Type=simple
    EnvironmentFile=/etc/default/node_exporter
    ExecStart=/usr/local/bin/node_exporter $OPTIONS

    [Install]
    WantedBy=multi-user.target
    ```    
    Создадим `node_exporter` пользователя командой `useradd --no-create-home --shell /bin/false node_exporter`  
    Назначим права на исполняемый файл командой `chown -R node_exporter:node_exporter /usr/local/bin/node_exporter`  
    Пересканируем созаднный сервис командой `sudo systemctl daemon-reload`   
    * поместите его в автозагрузку,  
    Включим сервис во время загрузки командой `systemctl enable node_exporter`  
    * предусмотрите возможность добавления опций к запускаемому процессу через внешний файл    
    Добавление опций (параметров) для запускаемого файла можно использовать переменные окружения  
    В unit-файле мы указали переменную `$OPTIONS` и файл с переменными в `EnvironmentFile`  
    Создадим файл `/etc/default/node_exporter` с переменными окружения для процесса node_exporter
        ```
        OPTIONS="--collector.disable-defaults --collector.cpu --collector.meminfo --collector.filesystem --collector.netdev"
        ```
        Проверим что переменная `OPTIONS` передаётся процессу командой `strings /proc/PID/environ`  
    * удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.  
    Запустим сервис комндой `systemctl status node_exporter`  
    Проверим статус сервиса командой `systemctl status node_exporter`  
    Посмотрим логи сериса командой `journalctl -f --unit node_exporter`  
    Перезагрузим машину командой `systemctl reboot` и убедимся что сервис запущен  

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
    
    Примеры метрик для мониторинга   
    * CPU  
        ```
        # HELP node_cpu_seconds_total Seconds the CPUs spent in each mode.
        node_cpu_seconds_total{cpu="*",mode="*"}
        # HELP process_cpu_seconds_total Total user and system CPU time spent in seconds.
        process_cpu_seconds_total
        ```
    * память  
        ```
        # HELP node_memory_MemAvailable_bytes Memory information field MemAvailable_bytes.
        node_memory_MemFree_bytes
        # HELP node_memory_SwapFree_bytes Memory information field SwapFree_bytes.
        node_memory_SwapFree_bytes
        # HELP process_virtual_memory_max_bytes Maximum amount of virtual memory available in bytes.
        process_virtual_memory_max_bytes
        ```
    * диск  
        ```
        # HELP node_filesystem_files_free Filesystem total free file nodes.
        node_filesystem_files_free{device="*",fstype="*",mountpoint="*"}
        # HELP node_filesystem_free_bytes Filesystem free space in bytes.
        node_filesystem_free_bytes{device="*",fstype="*",mountpoint="*"}
        ```
    * сеть  
        ```
        # HELP node_network_receive_drop_total Network device statistic receive_drop.
        node_network_receive_drop_total{device="*"}
        # HELP node_network_receive_errs_total Network device statistic receive_errs.
        node_network_receive_errs_total{device="*"}
        # HELP node_network_transmit_drop_total Network device statistic transmit_drop.
        node_network_transmit_drop_total{device="*"}
        # HELP node_network_transmit_errs_total Network device statistic transmit_errs.
        node_network_transmit_errs_total{device="*"}
        ```

3. Установите в свою виртуальную машину `Netdata`    
    * В браузере на своей машине зайдите на `localhost:19999`. Какие метрики по умолчанию собираются Netdata?  
    В начале выдаются общая загрузка по CPU, памяти, диску и сети. И затем ниже выдаётся подробные метрики. Например `softirq`.
  
1. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?  
Да, можно запустить команду `dmesg | grep -i virt`  
```
[    0.000000] DMI: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
[    0.002806] CPU MTRRs all blank - virtualized system.
[    0.101141] Booting paravirtualized kernel on KVM
[    7.628466] systemd[1]: Detected virtualization oracle.
```

3. Как настроен sysctl `fs.nr_open` на системе по-умолчанию?  
Запустим команду `sysctl -n fs.nr_open` и получим максимальное количество файловых дескрипторов, которые может выделить процесс. Оно ровно `1048576`  
    * Какой другой существующий лимит не позволит достичь такого числа?  
    Другой механизм, который обеспечивает контроль над ресурсами, доступными оболочке и запущенным ею процессам `ulimit -n`. Он равен `1024`  
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
