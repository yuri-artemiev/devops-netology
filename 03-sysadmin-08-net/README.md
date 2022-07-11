# Домашнее задание к занятию "3.8. Компьютерные сети, лекция 3"

1. Подключитесь к публичному маршрутизатору в интернет. Найдите маршрут к вашему публичному IP
    xxx
    ```
    telnet route-server.ip.tdc.net
    
    show route 93.165.158.150
    inet.0: 882857 destinations, 15008409 routes (882857 active, 0 holddown, 1 hidden)
    + = Active Route, - = Last Active, * = Both
    93.160.0.0/13      *[BGP/170] 6w3d 05:23:27, localpref 100, from 83.88.48.163
                          AS path: 3292 I, validation-state: unverified
                        > to 193.162.154.25 via fxp0.0
                        [BGP/170] 3w0d 14:51:08, localpref 100, from 83.88.49.1
                          AS path: 3292 I, validation-state: unverified
                        > to 193.162.154.25 via fxp0.0
                        [BGP/170] 3w5d 15:49:25, localpref 100, from 83.88.49.2
                          AS path: 3292 I, validation-state: unverified
                        > to 193.162.154.25 via fxp0.0
                        ...
                        [BGP/170] 3w5d 15:28:07, localpref 100, from 83.88.49.28
                          AS path: 3292 I, validation-state: unverified
                        > to 193.162.154.25 via fxp0.0
                        [BGP/170] 3w0d 16:05:31, localpref 100, from 83.88.49.93
                          AS path: 3292 I, validation-state: unverified
                        > to 193.162.154.25 via fxp0.0
                        [BGP/170] 3w0d 15:21:20, localpref 100, from 83.88.52.201
                          AS path: 3292 I, validation-state: unverified
                        > to 193.162.154.25 via fxp0.0
    
    show bgp summary
    Groups: 2 Peers: 34 Down peers: 0
    Table          Tot Paths  Act Paths Suppressed    History Damp State    Pending
    inet.0          15008509     882858          0          0          0          0
    inet6.0          2472609     145451          0          0          0          0
    Peer                  AS      InPkt     OutPkt    OutQ   Flaps Last Up/Dwn   State|#Active/Received/Accepted/Damped...
    83.88.48.163        3292   24789966     137938       0       3 6w3d 5:25:35  536121/882856/882856/0 0/0/0/0
    83.88.49.1          3292   13170329      65941       0       3 3w0d 14:53:45 1613/882856/882856/0 0/0/0/0
    83.88.49.2          3292   13685348      81317       0       4 3w5d 15:51:18 10717/882857/882857/0 0/0/0/0
    ...
    2001:6c8:40::22     3292   11485675      65975       0       7 3w0d 15:09:42 Establ   inet6.0: 1927/145450/145450/0
    2001:6c8:40::23     3292   13594694      81287       0       6 3w5d 15:37:18 Establ   inet6.0: 1234/145450/145450/0
    2001:6c8:40::13f    3292    9678855      66097       0       8 3w0d 16:07:03 Establ   inet6.0: 21/145451/145451/0
                        
    ```
2. Создайте dummy0 интерфейс в Ubuntu. Добавьте несколько статических маршрутов. Проверьте таблицу маршрутизации.
    xxx
    ```
    
    ```
3. Проверьте открытые TCP порты в Ubuntu, какие протоколы и приложения используют эти порты? Приведите несколько примеров.
    xxx
    ```
    
    ```
4. Проверьте используемые UDP сокеты в Ubuntu, какие протоколы и приложения используют эти порты?
    xxx
    ```
    
    ```
5. Используя diagrams.net, создайте L3 диаграмму вашей домашней сети или любой другой сети, с которой вы работали. 
    xxx
    ```
    
    ```
