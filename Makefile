# we need this for `make pkg`, since we do some directory traversal
SHELL:=/bin/bash

BASH_M4=completions/kbsecret.bash.m4
BASH_M4_OUT=completions/kbsecret.bash
ZSH_M4=completions/kbsecret.zsh.m4
ZSH_M4_OUT=completions/kbsecret.zsh
FISH_M4=completions/kbsecret.fish.m4
FISH_M4_OUT=completions/kbsecret.fish

override CMDS+=$(shell echo bin/kbsecret* | xargs basename -a | \
					sed 's/^kbsecret-\{0,1\}//g')

M4FLAGS:=-D__KBSECRET_INTROSPECTABLE_COMMANDS="$(CMDS)"

PKG=pkg
GEM_DEPS=$(PKG)/deps
PKGS=deb rpm pacman

.PHONY: all
all: completions doc man test

.PHONY: completions
completions: bash zsh fish

.PHONY: doc
doc:
	yardoc
	yard stats --list-undoc

.PHONY: man
man: ronnpp
	ronn --manual="KBSecret Manual" --html --roff man/*.ronn

.PHONY: ronnpp
ronnpp:
	for f in man/*.ronnpp; do ./man/ronnpp < $$f > man/$$(basename $$f .ronnpp).ronn; done

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
	rake test

.PHONY: bash
bash:
	m4 $(M4FLAGS) $(BASH_M4) > $(BASH_M4_OUT)

.PHONY: zsh
zsh: # XXX: implement

.PHONY: fish
fish: # XXX: implement

.PHONY: clean
clean:
	rm -f $(BASH_M4_OUT) $(ZSH_M4_OUT) $(FISH_M4_OUT)
	rm -rf doc/
	rm -rf man/*.html man/*.1 man/*.ronn
	rm -rf pkg/
