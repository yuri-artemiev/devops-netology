# Домашнее задание к занятию "3.3. Операционные системы, лекция 1"

1. Какой системный вызов делает команда `cd`?  
`chdir("/tmp") = 0`  
2. Используя `strace` выясните, где находится база данных `file` на основании которой она делает свои догадки.  
Используем фильтр системных вызывов, чтобы покатать вызов `openat`  
`strace -e openat file /dev/sda`   
```
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libmagic.so.1", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/liblzma.so.5", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libbz2.so.1.0", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libz.so.1", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/etc/magic.mgc", O_RDONLY) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3
openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3
openat(AT_FDCWD, "/usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache", O_RDONLY) = 3
/dev/sda: block special (253/0)
+++ exited with 0 +++
```
Выведем содержимое файла 
`cat /etc/magic`  
`# Magic local data for file(1) command.`  
И проверим тип файлов `magic`  
`file /usr/share/misc/magic.mgc`  
`/usr/share/misc/magic.mgc: symbolic link to ../../lib/file/magic.mgc`  
`file /usr/lib/file/magic.mgc`  
`/usr/lib/file/magic.mgc: magic binary file for file(1) cmd (version 14) (little endian)`  
Утилита `file` использует бинарный файл `/usr/lib/file/magic.mgc` для вывода типа файла  
3. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла.  
Запустим команду на запись в файл и отправим её в фон  
`ping localhost > ping-file.txt &`  
Проверим, что запись идёт  
`cat ping-file.txt`  
Посмотрим PID процесса записывающего в файл `ping-file.txt`  
`lsof ping-file.txt`  
```
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF    NODE NAME
ping    2082 root    1w   REG  253,0     1300 1703956 ping-file.txt
```
PID = `2082` , файловый дескриптор `1`   
Удалим файл и убедимся, что он удалён  
```
rm -rf ping-file.txt
lsof ping-file.txt
lsof: status error on ping-file.txt: No such file or directory
```
Вывдем список файлов открытых процессом, и отфильтруем удалённые файлы  
```
lsof -p 2082 | grep '(deleted)'
ping    2082 root    1w   REG  253,0     3010 1703956 /root/ping-file.txt (deleted)
```
Файл продолжает рости. Проверим куда ссылается дескриптор процесса  
```
ls -la /proc/2082/fd/1
l-wx------ 1 root root 64 Jun 19 13:46 /proc/2082/fd/1 -> '/root/ping-file.txt (deleted)'
```
Отправим значение `true` в файловый дескриптор и убедимся, что файл обнулился  
```
: > /proc/2082/fd/1
lsof -p 2082 | grep '(deleted)'
ping    2082 root    1w   REG  253,0        0     0 1703956 /root/ping-file.txt (deleted)

```

4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?  
Зомби-процессы не занимают какие-либо системные ресурсы, но сохраняют свой ID в таблице процессов, размер которой ограничен.  
5. На какие файлы вы увидели вызовы группы `open` за первую секунду работы утилиты opensnoop?  
```
opensnoop-bpfcc -T
TIME(s)       PID    COMM               FD ERR PATH
0.000000000   873    vminfo              5   0 /var/run/utmp
0.000136000   676    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
0.000160000   676    dbus-daemon        20   0 /usr/share/dbus-1/system-services
0.000221000   676    dbus-daemon        -1   2 /lib/dbus-1/system-services
0.000232000   676    dbus-daemon        20   0 /var/lib/snapd/dbus-1/system-services/
```
6. Какой системный вызов использует `uname -a`?  
Для остлеживания системных вызовов запустим комманду  
`strace uname -a`  
В самом конце вывода увидем вызов `uname` перед выводом  
```
uname({sysname="Linux", nodename="vagrant", ...}) = 0
fstat(1, {st_mode=S_IFCHR|0600, st_rdev=makedev(0x88, 0), ...}) = 0
uname({sysname="Linux", nodename="vagrant", ...}) = 0
uname({sysname="Linux", nodename="vagrant", ...}) = 0
write(1, "Linux vagrant 5.4.0-91-generic #"..., 106Linux vagrant 5.4.0-91-generic #102-Ubuntu SMP Fri Nov 5 16:31:28 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
) = 106
```
  Где в `/proc` можно узнать версию ядра и релиз ОС.  
Согласно man информация также доступна в `/proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}`  
```
cat /proc/sys/kernel/osrelease
5.4.0-91-generic
```
7. Чем отличается последовательность команд через `;` и через `&&` в bash?  
`;` - выполелнение нескольких команд последовательно. Все команды запустятся, не зависиомо от успеха любой из них    
`&&` - выполняет нескольких команд последовательно. Каждая команда после `&&` выполняется толко если предыдущая команда завершилась успешно (под завершения 0)   
  Есть ли смысл использовать в bash `&&`, если применить `set -e`?  
Команда `set` устанавливает переменные оболоички. С её помощью можно регулировать поведение оболочки.  
Параметр `-e` указывает оболочке выйти, если команда дает ненулевой статус выхода  
Документация bash указывает, что параметр `e` не выходит из оболочки, если команда, которая выдаёт ошибку, часть одной комманды, связанной `&&`. Исключение, если команда, выдающая ошибку, является последней в списке `&&`  
8. Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?  
Состоит из параметров  
`set -e` - выйти из оболочки, если команда завершилась неуспешно  
`set -u` - выйти из оболочки, если обращаются к переменной, которую не назначили  
`set -o pipefail` - код завершения pipe будет неуспешным, если любая из команд выдала ошибку  
`set -x` - выводить на терминал все запускаемые команды (помогает при дебаге)  
Установка параметров может задать режим более строгих требований к написанию скриптов, что может помочь в избежании некоторых багов  
9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе.  
Если вывести список всех процессов `ps -d -o stat`, то наиболее частый статус `I` - Idle kernel thread.  
Дополнительные статусы могу означать приоритет процесса, заблокированные страницы в памяти и т.д.  
  
 
