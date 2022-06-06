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

