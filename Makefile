# we need this for `make pkg`, since we do some directory traversal
SHELL:=/bin/bash

BASH_M4=completions/kbsecret.bash.m4
BASH_M4_OUT=completions/kbsecret.bash
ZSH_M4=completions/kbsecret.zsh.m4
ZSH_M4_OUT=completions/kbsecret.zsh

override CMDS+=$(shell echo lib/kbsecret/cli/kbsecret* | xargs basename -a | \
					sed 's/^kbsecret-\{0,1\}//g')

M4FLAGS:=-D__KBSECRET_INTROSPECTABLE_COMMANDS="$(CMDS)"
VERSION:=$(shell git describe --tags --abbrev=0 2>/dev/null \
			|| git rev-parse --short HEAD \
			|| echo "unknown-version")

PKG=pkg
GEM_DEPS=$(PKG)/deps
PKGS=deb rpm pacman

.PHONY: all
all: completions doc man test

.PHONY: completions
completions: bash zsh

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

.PHONY: pkg
pkg: $(PKGS)

.PHONY: $(PKGS)
$(PKGS): prep-gems
	pushd . && \
	mkdir -p $(PKG)/$@ && \
	cd $(PKG)/$@ && \
	find ../deps/cache -name "*.gem" | \
		xargs -rn1 fpm -d ruby -d rubygems \
		--gem-package-name-prefix "ruby" \
		--maintainer "william@yossarian.net" \
		-s gem -t $@ && \
	fpm --no-gem-fix-name --gem-package-name-prefix "ruby" \
		-s gem -t $@ kbsecret && \
	popd

.PHONY: prep-gems
prep-gems:
	mkdir -p pkg/deps
	gem install --norc --no-ri --no-rdoc --install-dir $(GEM_DEPS) kbsecret
	rm -f $(GEM_DEPS)/cache/kbsecret-*.gem

.PHONY: test
test:
	bundle exec rake test
	TEST_NO_KEYBASE=1 bundle exec rake test

.PHONY: test-cli
test-cli:
	bundle exec ruby -I lib:test test/cli/test_all.rb

.PHONY: coverage
coverage:
	COVERAGE=1 bundle exec rake test

.PHONY: bash
bash:
	m4 $(M4FLAGS) $(BASH_M4) > $(BASH_M4_OUT)

.PHONY: clean
clean:
	rm -f $(BASH_M4_OUT) $(ZSH_M4_OUT)
	rm -rf doc/
	rm -rf man/man{1,5}/*.{html,1,5,ronn}
	rm -rf pkg/
	rm -rf coverage/
