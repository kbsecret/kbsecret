# we need this for `make pkg`, since we do some directory traversal
SHELL:=/bin/bash

BASH_M4=completions/kbsecret.bash.m4
BASH_M4_OUT=completions/kbsecret.bash

override CMDS+=$(shell echo lib/kbsecret/cli/kbsecret* | xargs basename -a | \
					sed 's/^kbsecret-\{0,1\}//g')

M4FLAGS:=-D__KBSECRET_INTROSPECTABLE_COMMANDS="$(CMDS)"
VERSION:=$(shell git describe --tags --abbrev=0 2>/dev/null \
			|| git rev-parse --short HEAD \
			|| echo "unknown-version")

.PHONY: all
all: completions doc man test

.PHONY: completions
completions: bash

.PHONY: doc
doc:
	yardoc
	yard stats --list-undoc

.PHONY: man-www
man-www: man
	mkdir ../kbsecret.github.io/man/$(VERSION)
	cp man/man{1,5}/*.html ../kbsecret.github.io/man/$(VERSION)/
	sed -i '1i* [$(VERSION)]($(VERSION)/kbsecret.1)' ../kbsecret.github.io/man/_manvers.md

.PHONY: man
man: ronnpp
	ronn --organization="$(VERSION)" --manual="KBSecret Manual" \
	--html --roff --style toc,80c \
	man/man{1,5}/*.ronn

.PHONY: ronnpp
ronnpp:
	for f in man/man1/*.ronnpp; do ./man/ronnpp < $$f > man/man1/$$(basename $$f .ronnpp).ronn; done
	for f in man/man5/*.ronnpp; do ./man/ronnpp < $$f > man/man5/$$(basename $$f .ronnpp).ronn; done

.PHONY: test
test:
	bundle exec rake test

.PHONY: test-cli
test-cli:
	bundle exec rake test-cli

.PHONY: coverage
coverage:
	COVERAGE=1 bundle exec rake test

.PHONY: lint
lint:
	bundle exec rubocop lib/ test/

.PHONY: bash
bash:
	m4 $(M4FLAGS) $(BASH_M4) > $(BASH_M4_OUT)

.PHONY: clean
clean:
	rm -f $(BASH_M4_OUT)
	rm -rf doc/
	rm -rf man/man{1,5}/*.{html,1,5,ronn}
	rm -rf coverage/
