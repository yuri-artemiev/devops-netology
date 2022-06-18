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
...  
4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?  
...  
5. На какие файлы вы увидели вызовы группы `open` за первую секунду работы утилиты opensnoop?  
...  
6. Какой системный вызов использует `uname -a`?  
...  
Где в `/proc` можно узнать версию ядра и релиз ОС.  
...  
7. Чем отличается последовательность команд через `;` и через `&&` в bash?  
...  
Есть ли смысл использовать в bash `&&`, если применить `set -e`?  
...  
8. Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?  
...  
9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе.  
...  
 
