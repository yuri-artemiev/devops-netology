# Домашнее задание к занятию "3.5. Файловые системы"

1. Узнайте о sparse (разряженных) файлах.  
...  
1. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?  
...  
1. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.  
...  
1. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.  
...  
1. Соберите `mdadm` RAID1 на паре разделов 2 Гб.  
...  
1. Соберите `mdadm` RAID0 на второй паре маленьких разделов.  
...  
1. Создайте 2 независимых PV на получившихся md-устройствах.  
...  
1. Создайте общую volume-group на этих двух PV.  
...  
1. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.  
...  
1. Создайте `mkfs.ext4` ФС на получившемся LV.  
...  
1. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.  
...  
1. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.  
...  
1. Прикрепите вывод `lsblk`.  
...  
1. Протестируйте целостность файла  
...  
1. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.  
...  
1. Сделайте `--fail` на устройство в вашем RAID1 md.  
...  
1. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.  
...  
1. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:  
...  
  