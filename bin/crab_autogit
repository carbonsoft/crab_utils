#!/bin/bash

set -eu
. /opt/crab/crab_utils/bin/::carbon.sys

sys::usage "$@"
### --help Автоматически создавать и коммитить все файлы в каталоге
### --help Example: auto_git.sh /var/www/html

log() {
	echo "$@"
	return 0
}


dir="${1}"
log "Запускаем скрипт для каталога $dir"
if [ ! -d "$dir/" ]; then
	log "Не найден каталог. $dir"
	exit 255
fi

cd "$dir/"
(
	cd ..
	[ -d ".git" ] && git pull
	exit 0
)
init_repo() {
	log "Инициализируем новый репозиторий"
	git init
	git add .
	git commit -m "Initial commit" &>/dev/null
	return 0
}

add_commit() {
	git add .
	git commit -am "autocommit $0 $@" || true
	return 0
}


if [ ! -d ".git" ]; then
	init_repo
	exit 0
fi

if ! git status &>/dev/null; then
	log "Ошибка git репозитория! `git status`"
	log "Создаем новый репозиторий!"
	mv .git .git.`date +%s`
	init_repo
	exit 0
fi

add_commit
if git remote show origin &>/dev/null; then
	git pull origin master
	git push origin master
fi
exit 0
