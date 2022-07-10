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
    Используется протокол `LLDP`. Также `ARP` используется для разерешения IP адреса в MAC адрес.  
    Какой пакет и команды есть в Linux для этого?  
    Используется пакет `lldpd`
    ```
    apt info lldpd
    ...
    This implementation provides LLDP sending and reception, supports VLAN and includes an SNMP subagent that can interface to an SNMP agent through AgentX protocol.
    ...
    ```    
3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей?  
    Используется технология `VLAN` - виртуальных частных сетей. Для изоляции широковещательных доменов.  

    Какой пакет и команды есть в Linux для этого? Приведите пример конфига.
    Восопользуетмся командой `ip`  
    ```
    ip link add link eth0 name eth0.10 type vlan id 10
    ip -d link show eth0.10
    ip addr add 192.168.1.200/24 brd 192.168.1.255 dev eth0.10
    ip link set dev eth0.10 up
    ip link set dev eth0.10 down
    ip link delete eth0.10
    
    ip link add link enp1s0 name enp1s0.100 type vlan id 100
    ip addr add 192.168.100.2/24 dev enp1s0.100
    nano /etc/netplan/01-network-manager-all.yaml
    network:
    ethernets:
    enp1s0:
      dhcp4: false
      addresses:
        - 192.168.122.201/24
      gateway4: 192.168.122.1
      nameservers:
          addresses: [8.8.8.8, 1.1.1.1]

    vlans:
        enp1s0.100:
            id: 100
            link: enp1s0
            addresses: [192.168.100.2/24]
    netplan apply        
    
    
    ```
4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.
    ```
    
    ```
5. Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.
    ```
    
    ```
6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.
    ```
    
    ```
7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?
    ```
    
    ```

