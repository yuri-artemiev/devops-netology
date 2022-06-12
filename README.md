# devops-netology
Файлы исключенные из системы контроля версий Git (gitignore):  
- Директории .terraform  
- Файлы .tfstate  
- Лог файлы crash.log  
- Файлы с переменными, которые могут содержать пароли, .tfvars  
- Файлы с переопределёнными настройками override.tf  
- Файлы c конфигурацией терминала (CLI) .terraformrc  

**Merge и Rebase вывод git**  
```
*   ebf0d6a (HEAD -> main, origin/main, origin/HEAD, gitlab/main, bitbucket/main) Merge branch 'git-rebase'
|\
| *   65cfc6f (origin/git-rebase, gitlab/git-rebase, bitbucket/git-rebase, git-rebase) Merge branch 'git-merge'
| |\
* | \   9e2f1c3 Merge branch 'git-merge'
|\ \ \
| |/ /
|/| /
| |/
| * c72ad71 (origin/git-merge, gitlab/git-merge, bitbucket/git-merge, git-merge) merge: use shift
| * df2d78f merge: @ instead *
* | 90758ce rebase: use =====
|/
* d53c7ae prepare for merge and rebase
* 123d98e (tag: v0.1, tag: v0.0) Moved and deleted
| * 92ba173 (origin/fix, fix) Updated README.md in PyCharm
| * dbfda8f New brach fix created
|/
* 47892f4 Prepare to delete and move
* a3cd0b3 Updated README.md
* 1440559 Added gitignore
* 9a73b0e First commit
* 41dfa52 Initial commit
```

# Домашнее задание к занятию «2.4. Инструменты Git»  

1. Найдите полный хеш и комментарий коммита, хеш которого начинается на aefea.  
Полный хэш `aefead2207ef7e2aa5dc81a34aedf0cad4c32545`  
Коммантарий `Update CHANGELOG.md`  
Команда `git show -s aefea`  
2. Какому тегу соответствует коммит 85024d3?  
Тег `v0.12.23`  
Команда `git show -s 85024d3`  
3. Сколько родителей у коммита b8d720? Напишите их хеши.  
Два родителя (мерж коммит)  
Хеш 1 `56cd7859e05c36c06b56d013b55a252d0bb7e158`  
Хеш 2 `9ea88f22fc6269854151c571162c5bcf958bee2b`  
Команда `git show -s --pretty=%P b8d720`  
4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.  
```
33ff1c03b (tag: v0.12.24) v0.12.24
b14b74c49 [Website] vmc provider links
3f235065b Update CHANGELOG.md
6ae64e247 registry: Fix panic when server is unreachable
5c619ca1b website: Remove links to the getting started guide's old location
06275647e Update CHANGELOG.md
d5f9411f5 command: Fix bug when using terraform login on Windows
4b6d06cc5 Update CHANGELOG.md
dd01a3507 Update CHANGELOG.md
225466bc3 Cleanup after v0.12.23 release
```
Команда `git show -s --oneline v0.12.23..v0.12.24`  
5. Найдите коммит в котором была создана функция func providerSource, ее определение в коде выглядит так func providerSource(...) (вместо троеточего перечислены аргументы).  
Коммит `8c928e835`  
Команда `git log --oneline -S 'func providerSource('`  
6. Найдите все коммиты в которых была изменена функция globalPluginDirs.  
Коммиты  
```
78b122055 Remove config.go and update things using its aliases
52dbf9483 keep .terraform.d/plugins for discovery
41ab0aef7 Add missing OS_ARCH dir to global plugin paths
66ebff90c move some more plugin search path logic to command
8364383c3 Push plugin discovery down into command package
```
Команды  
Найти файл, в котором объявляется функция `git grep "func globalPluginDirs("`  
Найти имзенения в файле plugins.go, связанные с изменением этой функции `git log -L:globalPluginDirs:plugins.go --oneline -s`  
7. Кто автор функции synchronizedWriters?  
Автор `Martin Atkins <mart@degeneration.co.uk>`  
Команда `git log -S 'func synchronizedWriters('`  

# Домашнее задание к занятию «3.1. Работа в терминале, лекция 1»  
5. Какие ресурсы выделены по-умолчанию?  
Выделено 2 CPU, 1024 MB RAM, 64 GB disk  
6. Как добавить оперативной памяти или ресурсов процессора виртуальной машине?  
Отредактировать файл Vagrantfile в директории, где хранятся файлы конфигурации  
```
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.provider "virtualbox" do |v|
    v.memory = 4128
    v.cpus = 4
  end
```
Проверить корректность Vagrantfile файла можно командой `vagrant validate`  
Перезапустить виртуальную машину можно командой `vagrant reload`  
8. Ознакомиться с разделами man bash, почитать о настройках самого bash:  
    - какой переменной можно задать длину журнала `history`, и на какой строчке manual это описывается?  
    `HISTSIZE` - количество команд, которые будут запоминаться в истории. В 862 строке манула.  
    `HISTFILESIZE` - количество строк, которыу будут записываться в файле истории. В 846 строке мануала.  
    - что делает директива `ignoreboth` в bash?  
    Это возможное значение переменной `HISTCONTROL`. `ignoreboth` задаёт запрет на сохранение в истории строк, начинающихся с пробела, и строк, совпадающих с предыдущей командой.  
9. В каких сценариях использования применимы скобки {} и на какой строчке man bash это описано?
Фигурные скобки обозначают список. Он запускает команду в текущей оболочке. В 257 строке мануала.  
10. С учётом ответа на предыдущий вопрос, как создать однократным вызовом touch 100000 файлов? Получится ли аналогичным образом создать 300000? Если нет, то почему?  
    - Командой `touch {0..100000}` можно создать 100000 файлов.  
    - Команда `touch {0..300000}` выдаёт ошибку `/usr/bin/touch: Argument list too long`  
    Эта ошибка обозначает, что количество аргументов в команде превысило значение `ARG_MAX`. `ARG_MAX` обозначает максимальную длинну аргументов. Аргументы вводятся в терминале после названия команды. Множество аргументов может передаваться за один раз. Для просмотра лимита аргументов можно использовать команду `getconf ARG_MAX`. Ограничение в 2097152 байт.  
11. В man bash поищите по `/\[\[`. Что делает конструкция [[ -d /tmp ]]  
`[[ условие ]]` возвращает 0 или 1 в зависимости от условного выражения. Условие  `-d /tmp` возвращает 0, если файл существует и является директорией.  
12. Добейтесь в выводе type -a bash в виртуальной машине наличия первым пунктом в списке: bash is /tmp/new_path_directory/bash  
```
# Создаём директорию
mkdir /tmp/new_path_directory 

# Копируем в неё файл bash
cp /bin/bash /tmp/new_path_directory/

# Добавляем каталог в переменную $PATH (в начало) 
PATH=/tmp/new_path_directory/bash:$PATH
```
13. Чем отличается планирование команд с помощью batch и at?  
`at` - запланировать однократный запуск команды в заданное время  
`batch` - запланировать запуск команды, когда загрузка упадёт ниже  1,5 

# Домашнее задание к занятию "3.2. Работа в терминале, лекция 2"

1. Какого типа команда cd?  
Для проверки типа команды можно использовать команду `type`  
```
type cd
cd is a shell builtin
```
2. Какая альтернатива без pipe команде grep <some_string> <some_file> | wc -l?  
...  
3. Какой процесс с PID 1 является родителем для всех процессов в вашей виртуальной машине Ubuntu 20.04?  
...  
4. Как будет выглядеть команда, которая перенаправит вывод stderr ls на другую сессию терминала?  
...  
5. Получится ли одновременно передать команде файл на stdin и вывести ее stdout в другой файл?  
...  
6. Получится ли находясь в графическом режиме, вывести данные из PTY в какой-либо из эмуляторов TTY?  
...  
7. Выполните команду bash 5>&1. К чему она приведет?  
    - Что будет, если вы выполните echo netology > /proc/$$/fd/5  

8. Получится ли в качестве входного потока для pipe использовать только stderr команды, не потеряв при этом отображение stdout на pty?  
...  
9. Что выведет команда cat /proc/$$/environ?  
...  
10. Что доступно по адресам /proc/PID/cmdline, /proc/PID/exe?  
...  
11. Какую наиболее старшую версию набора инструкций SSE поддерживает ваш процессор с помощью /proc/cpuinfo?  
...  
12. Почему так происходит, в команде ниже?  
```
vagrant@netology1:~$ ssh localhost 'tty'  
not a tty  
```
13. Как переместить запущенный процесс из одной сессии в другую, воспользовавшись `reptyr`?  
...  
14. Что делает команда tee в команде ниже и почему в отличие от sudo echo команда с sudo tee будет работать?  
`echo string | sudo tee /root/new_file`  
...  



 

