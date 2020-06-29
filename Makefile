#!make

BIN ?= git-profile
PREFIX ?= /usr/local

install:
	cp git-profile.sh $(PREFIX)/bin/$(BIN)
	chmod +x $(PREFIX)/bin/$(BIN)

lint:
	shellcheck *.sh

push:
	git config credential.helper 'cache --timeout=3600'
	git pull
	git add .
	git commit -am "push"
	git push

fork:
	curl -sL git.io/fork.sh | bash -
