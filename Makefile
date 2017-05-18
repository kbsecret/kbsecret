BASH_M4=completions/kbsecret.bash.m4
BASH_M4_OUT=completions/kbsecret.bash
ZSH_M4=completions/kbsecret.zsh.m4
ZSH_M4_OUT=completions/kbsecret.zsh
FISH_M4=completions/kbsecret.fish.m4
FISH_M4_OUT=completions/kbsecret.fish

override CMDS+=$(shell echo bin/kbsecret* | xargs basename -a | \
					sed 's/^kbsecret-\{0,1\}//g')

M4FLAGS:=-D__KBSECRET_INTROSPECTABLE_COMMANDS="$(CMDS)"

.PHONY: doc clean

all: completions

completions: bash zsh fish

doc:
	yardoc
	yard stats --list-undoc

bash:
	m4 $(M4FLAGS) $(BASH_M4) > $(BASH_M4_OUT)

zsh: # XXX: implement

fish: # XXX: implement

clean:
	rm -f $(BASH_M4_OUT) $(ZSH_M4_OUT) $(FISH_M4_OUT)
	rm -r doc/
