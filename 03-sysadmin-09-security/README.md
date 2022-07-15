# Домашнее задание к занятию "3.9. Элементы безопасности информационных систем"

1. Установите Bitwarden плагин для браузера. Зарегестрируйтесь и сохраните несколько паролей.
    Не использую менеджеры паролей в браузере.

2. Установите Google authenticator на мобильный телефон. Настройте вход в Bitwarden акаунт через Google authenticator OTP.
    Не использую аутентификаторы в телефоне.
    
3. Установите apache2, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS.
    Установим apache
    ```
    apt install apache
    ```
    Включим ssl модуль
    ```
    a2enmod ssl
    systemctl restart apache2
    ```
    Сгенерируем самоподписанный сертификат
    ```
    openssl req -x509 -nodes -newkey rsa:4096 -sha256 -keyout /etc/ssl/private/private-selfsigned.key -out /etc/ssl/certs/certificated-selfsigned.crt -days 36160  -subj -sha256 -subj "/C=RU/O=Company/OU=DevOps/CN=www.example.com" -addext "subjectAltName=DNS:example.com,DNS:www.example.com" -addext "keyUsage = digitalSignature, keyEncipherment, dataEncipherment, cRLSign, keyCertSign" -addext "extendedKeyUsage = serverAuth, clientAuth" 
    ```
    Создадим конфигурацию нового сайта
    ```
    nano /etc/apache2/sites-available/example.com.conf
        <VirtualHost *:443>
        ServerName example.com
        DocumentRoot /var/www/example.com
        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/certificated-selfsigned.crt
        SSLCertificateKeyFile /etc/ssl/private/private-selfsigned.key
        </VirtualHost>
    ```
    Cоздадим директорию нового сайта
    ```
    mkdir /var/www/example.com
    nano /var/www/example.com/index.html
        Hello world!
    ```
    Включим новый сайт
    ```
    a2ensite example.com.conf
    systemctl reload apache2
    ```
    Пробросим порт `443` из вирутальной машины на хост порт `4443`.  
    Попробуем открыть в браузере сайт.  
    ![03-sysadmin-09-security-01.png](03-sysadmin-09-security-01.png)  
    Проверим сайт утилитой `curl`
    ```
    curl https://example.com:4443 --verbose --insecure
    *   Trying 127.0.0.1:4443...
    * Connected to example.com (127.0.0.1) port 4443 (#0)
    * ALPN: offers h2
    * ALPN: offers http/1.1
    * TLSv1.0 (OUT), TLS header, Certificate Status (22):
    * TLSv1.3 (OUT), TLS handshake, Client hello (1):
    * TLSv1.2 (IN), TLS header, Certificate Status (22):
    * TLSv1.3 (IN), TLS handshake, Server hello (2):
    * TLSv1.2 (IN), TLS header, Finished (20):
    * TLSv1.2 (IN), TLS header, Supplemental data (23):
    * TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
    * TLSv1.2 (IN), TLS header, Supplemental data (23):
    * TLSv1.3 (IN), TLS handshake, Certificate (11):
    * TLSv1.2 (IN), TLS header, Supplemental data (23):
    * TLSv1.3 (IN), TLS handshake, CERT verify (15):
    * TLSv1.2 (IN), TLS header, Supplemental data (23):
    * TLSv1.3 (IN), TLS handshake, Finished (20):
    * TLSv1.2 (OUT), TLS header, Finished (20):
    * TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
    * TLSv1.2 (OUT), TLS header, Supplemental data (23):
    * TLSv1.3 (OUT), TLS handshake, Finished (20):
    * SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
    * ALPN: server accepted http/1.1
    * Server certificate:
    *  subject: C=RU; O=Company; OU=DevOps; CN=www.example.com
    *  start date: Jul 15 07:55:23 2022 GMT
    *  expire date: Jul 16 07:55:23 2121 GMT
    *  issuer: C=RU; O=Company; OU=DevOps; CN=www.example.com
    *  SSL certificate verify result: self-signed certificate (18), continuing anyway.
    * TLSv1.2 (OUT), TLS header, Supplemental data (23):
    > GET / HTTP/1.1
    > Host: example.com:4443
    > User-Agent: curl/7.84.0
    > Accept: */*
    >
    * TLSv1.2 (IN), TLS header, Supplemental data (23):
    * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
    * TLSv1.2 (IN), TLS header, Supplemental data (23):
    * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
    * old SSL session ID is stale, removing
    * TLSv1.2 (IN), TLS header, Supplemental data (23):
    * Mark bundle as not supporting multiuse
    < HTTP/1.1 200 OK
    < Date: Fri, 15 Jul 2022 08:25:51 GMT
    < Server: Apache/2.4.41 (Ubuntu)
    < Last-Modified: Fri, 15 Jul 2022 08:04:44 GMT
    < ETag: "e-5e3d378951099"
    < Accept-Ranges: bytes
    < Content-Length: 14
    < Content-Type: text/html
    <
    Hello world!
    ```
4. Проверьте на TLS уязвимости произвольный сайт в интернете (кроме сайтов МВД, ФСБ, МинОбр, НацБанк, РосКосмос, РосАтом, РосНАНО и любых госкомпаний, объектов КИИ, ВПК ... и тому подобное).
    xxx
    ```
    
    ```
5. Установите на Ubuntu ssh сервер, сгенерируйте новый приватный ключ. Скопируйте свой публичный ключ на другой сервер. Подключитесь к серверу по SSH-ключу.
    xxx
    ```
    
    ```
6. Переименуйте файлы ключей из задания 5. Настройте файл конфигурации SSH клиента, так чтобы вход на удаленный сервер осуществлялся по имени сервера.
    xxx
    ```
    
    ```
7. Соберите дамп трафика утилитой tcpdump в формате pcap, 100 пакетов. Откройте файл pcap в Wireshark.
    xxx
    ```
    
    ```
