# Домашнее задание к занятию "3.7. Компьютерные сети, лекция 2"

1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?  
    На Linux запустим команду `ip`  
    ```
    ip a
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
        inet6 ::1/128 scope host
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 08:00:27:b1:28:5d brd ff:ff:ff:ff:ff:ff
        inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
        inet6 fe80::a00:27ff:feb1:285d/64 scope link
    ```
    или  
    ```
    ip link show
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
        link/ether 08:00:27:b1:28:5d brd ff:ff:ff:ff:ff:ff
    ```
    На Windows запустим команду `ipconfig`  
    ```
    Адаптер Ethernet Ethernet:
        DNS-суффикс подключения . . . . . : rt-ac66u
        Локальный IPv6-адрес канала . . . : fe80::dd14:7483:ff91:78dd%17
        IPv4-адрес. . . . . . . . . . . . : 192.168.1.10
        Маска подсети . . . . . . . . . . : 255.255.255.0
        Основной шлюз . . . . . . . . . . : 192.168.1.1
    Адаптер Ethernet VirtualBox Host-Only Network:
        DNS-суффикс подключения . . . . . :
        Локальный IPv6-адрес канала . . . : fe80::a5bd:4b43:db9c:e579%16
        IPv4-адрес. . . . . . . . . . . . : 192.168.56.1
        Маска подсети . . . . . . . . . . : 255.255.255.0
        Основной шлюз . . . . . . . . . . :
    ```

2. Какой протокол используется для распознавания соседа по сетевому интерфейсу?  
    Используется протокол `LLDP`. А также протокол `ARP` используется для разерешения IP адреса в MAC адрес.  
    * Какой пакет и команды есть в Linux для этого?  
        Используется пакет `lldpd`  
        ```
        apt info lldpd
        ...
        This implementation provides LLDP sending and reception, supports VLAN and includes an SNMP subagent that can interface to an SNMP agent through AgentX protocol.
        ...
        ```    
3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей?  
    Используется технология `VLAN` - виртуальных частных сетей. Для изоляции широковещательных доменов.  
    * Какой пакет и команды есть в Linux для этого? Приведите пример конфига  
        Используется утилита `ip` из пакета `iproute2`  
        ```
        ip link add link eth0 name eth0.10 type vlan id 10
        ip -d link show eth0.10
            3: eth0.10@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
                link/ether 08:00:27:b1:28:5d brd ff:ff:ff:ff:ff:ff
        ip addr add 10.0.10.15/24 brd 10.0.10.255 dev eth0.10
        ip link set dev eth0.10 up
        ip -d addr show eth0.10
            3: eth0.10@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
                link/ether 08:00:27:b1:28:5d brd ff:ff:ff:ff:ff:ff promiscuity 0 minmtu 0 maxmtu 65535
                vlan protocol 802.1Q id 10 <REORDER_HDR> numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
                inet 10.0.10.15/24 brd 10.0.10.255 scope global eth0.10
                    valid_lft forever preferred_lft forever
                inet6 fe80::a00:27ff:feb1:285d/64 scope link
                    valid_lft forever preferred_lft forever   
        ```
        Команда `ip` не сохраняет конфигурацию после перезагрузки   
        ```
        systemctl reboot
        ip -d link show
            1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
                link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00 promiscuity 0 minmtu 0 maxmtu 0 addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
            2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
                link/ether 08:00:27:b1:28:5d brd ff:ff:ff:ff:ff:ff promiscuity 0 minmtu 46 maxmtu 16110 addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
        ```
        Для сохранения конфигураци после перезагрузки используем систему `netplan` отредактировав файл конфигурации `/etc/netplan/01-netcfg.yaml`  
        ```
        network:
            version: 2
            ethernets:
                eth0:
                    dhcp4: true
            vlans:
                eth0.10:
                    id: 10
                    link: eth0
                    addresses: [10.0.10.15/24]
        ```       
        Применим конфигурацию командой `netplan apply`  
        Проверим что применилось командой `ip -d addr show eth0.10`  
        ```
        3: eth0.10@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
            link/ether 08:00:27:b1:28:5d brd ff:ff:ff:ff:ff:ff promiscuity 0 minmtu 0 maxmtu 65535
            vlan protocol 802.1Q id 10 <REORDER_HDR> numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
            inet 10.0.10.15/24 brd 10.0.10.255 scope global eth0.10
                valid_lft forever preferred_lft forever
            inet6 fe80::a00:27ff:feb1:285d/64 scope link
                valid_lft forever preferred_lft forever
        ```
4. Какие типы агрегации интерфейсов есть в Linux?   
    Аггрегация интерфейсов позволяет объединить несколько интерфейсов в один логический интерфейс. Это повышает пропускную способность и отказоустойчивость. В среде Linux используется названия NIC teaming или bonding.  
    * Какие опции есть для балансировки нагрузки?  
        Существуют разные режим балансировки в агрегации каналов  
        ```
        Round Robin
        Active Backup
        XOR
        Broadcast
        Dynamic Link Aggregation (LACP)
        Transmit Load Balancing (TLB)
        Adaptive Load Balancing (ALB)
        ```
    * Приведите пример конфига.  
        Пример для конфигурации LACP на двух интерфейсах:  
        ```
        network:
            version: 2    
            ethernets:
                eth0:
                    dhcp4: false
                eth1:
                    dhcp4: false
            bonds:
                bond0:
                    interfaces: [eth0, eth1]
                    parameters:
                        mode: 802.3ad
        ```
    

5. Сколько IP адресов в сети с маской /29 ?  
    В сети с маской `/29` доступны 6 адресов, например в 10.10.10.0/29 сети: 10.10.10.1-10.10.10.6 адреса. Два специальных адреса: 10.10.10.0 - адрес сети, 10.10.10.7 - широковещательный.  
    * Сколько /29 подсетей можно получить из сети с маской /24.  
        В сети `/24` 256 адресов (включая специальные), в сети `/29` 8 адресов. 256/8 = 32 подсети. 
    * Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.  
        Например, сеть 10.10.10.0/24: первая 10.10.10.0/29, последняя 10.10.10.248/29. 
6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса?  
    Можно использовать Carrier-grade NAT блок адресов 100.64.0.0/10.  
    * Маску выберите из расчета максимум 40-50 хостов внутри подсети.  
        Пример сети для 62 адресов в начале блока: `100.64.0.0/26`.  
7. Как проверить ARP таблицу в Linux, Windows?  
    Ubuntu  
    ```
    ip neighbour show
    ```
    Windows  
    ```
    arp -a
    ```
    * Как очистить ARP кеш полностью?  
        Ubuntu  
        ```
        ip neighbour flush all
        ```
        Windows  
        ```
        arp -d *
        ```
    * Как из ARP таблицы удалить только один нужный IP?  
        Ubuntu  
        ```
        ip neighbour del [ip address]
        ```
        Windows  
        ```
        arp -d [ip address]
        ```
