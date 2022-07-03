# Домашнее задание к занятию "3.5. Файловые системы"

1. Узнайте о sparse (разряженных) файлах.  
    Разряженный файл - файл в котором, последовательности нулевых байтов заменены на информацию об этих последовательностях. Эта информация храниться в метаданных файловой системы.  
1. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?  
    Права доступа у всех жёстких сылок одинаковы. Потому что inode содержит информацию о правах доступа. А inode у жётских ссылок одинаковый.  
1. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.  
    Результат после разбивки:  
    ```
    fdisk -l /dev/sdb
    Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
    ...
    Device     Boot   Start     End Sectors  Size Id Type
    /dev/sdb1          2048 4196351 4194304    2G 83 Linux
    /dev/sdb2       4196352 5242879 1046528  511M 83 Linux
    ```

1. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.  
    Команда `sfdisk -d` выводит содержание таблицы разделов (dump) по умолчанию на экран (stdout). Её вывод можно перенаправить для создание таблцицы разделов на втором диске.  
    `sfdisk -d /dev/sdb | sfdisk /dev/sdc`  
    Результат на втором диске:  
    ```
    fdisk -l /dev/sdc
    Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
    ...
    Device     Boot   Start     End Sectors  Size Id Type
    /dev/sdc1          2048 4196351 4194304    2G 83 Linux
    /dev/sdc2       4196352 5242879 1046528  511M 83 Linux
    ```
  
1. Соберите `mdadm` RAID1 на паре разделов 2 Гб.  
    Запустим команду  `mdadm --create --verbose --level=raid1 --raid-devices=2 /dev/md0 /dev/sdb1 /dev/sdc1`  
    Проверим статус `md0` командой `cat /proc/mdstat`  
    ```
    md0 : active raid1 sdc1[1] sdb1[0]
    2094080 blocks super 1.2 [2/2] [UU]
    ```
    
1. Соберите `mdadm` RAID0 на второй паре маленьких разделов.  
    Запустим команду  `mdadm --create --verbose --level=raid0 --raid-devices=2 /dev/md1 /dev/sdb2 /dev/sdc2`  
    Проверим статус `md1` командой `cat /proc/mdstat`  
    ```
    md1 : active raid0 sdc2[1] sdb2[0]
    1042432 blocks super 1.2 512k chunks
    ```
    
1. Создайте 2 независимых PV на получившихся md-устройствах.  
    Запустим коммаду `pvcreate /dev/md0 /dev/md1`  
    Проверитм что PV создались командой `pvs`  
    ```
    PV         VG        Fmt  Attr PSize    PFree
    /dev/md0             lvm2 ---    <2.00g   <2.00g
    /dev/md1             lvm2 ---  1018.00m 1018.00m
    ```
    
1. Создайте общую volume-group на этих двух PV.  
    Запустим команду `vgcreate vg0  /dev/md0 /dev/md1` 
    Проверим что VG создалась командой `vgs` 
    ```
    VG        #PV #LV #SN Attr   VSize   VFree
    vg0         2   0   0 wz--n-  <2.99g  <2.99g
    ```
    
1. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.  
    Запустим команду `lvcreate --size 100M --name lv0 vg0 /dev/md1`  
    где:  
        * `lv0` - имя logical volume  
        * `vg0` - имя volume group  
        * `/dev/md1` - physical volume на RAID0 на малых разелах 
    Проверим что LV созадлась командой `lvs` 
    ```
    LV        VG        Attr       LSize
    lv0       vg0       -wi-a----- 100.00m
    ```
1. Создайте `mkfs.ext4` ФС на получившемся LV.  
    ` mkfs.ext4 /dev/vg0/lv0`  
1. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.  
    ```
    mkdir /tmp/new
    mount /dev/vg0/lv0 /tmp/new
    ```
1. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.  
    Проверим что файл скачался командой `ls -la /tmp/new/test.gz`  
    ```
    -rw-r--r-- 1 root root 23701152 Jul  3 14:18 /tmp/new/test.gz
    ```
1. Прикрепите вывод `lsblk`. 
    ``` 
    NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
    sda                         8:0    0   64G  0 disk
    ├─sda1                      8:1    0    1M  0 part
    ├─sda2                      8:2    0    1G  0 part  /boot
    └─sda3                      8:3    0   63G  0 part
      └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm   /
    sdb                         8:16   0  2.5G  0 disk
    ├─sdb1                      8:17   0    2G  0 part
    │ └─md0                     9:0    0    2G  0 raid1
    └─sdb2                      8:18   0  511M  0 part
      └─md1                     9:1    0 1018M  0 raid0
        └─vg0-lv0             253:1    0  100M  0 lvm   /tmp/new
    sdc                         8:32   0  2.5G  0 disk
    ├─sdc1                      8:33   0    2G  0 part
    │ └─md0                     9:0    0    2G  0 raid1
    └─sdc2                      8:34   0  511M  0 part
      └─md1                     9:1    0 1018M  0 raid0
        └─vg0-lv0             253:1    0  100M  0 lvm   /tmp/new  
    ```
1. Протестируйте целостность файла  
...  
1. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.  
    `/dev/md0` - RAID1 на больших разелах  
1. Сделайте `--fail` на устройство в вашем RAID1 md.  
...  
1. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.  
...  
1. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:  
...  
  
