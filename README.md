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

