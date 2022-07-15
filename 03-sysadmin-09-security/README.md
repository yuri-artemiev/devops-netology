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
