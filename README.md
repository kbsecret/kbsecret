KBSecret ![](https://kbsecret.github.io/res/logo50.png)
========

[![Gem Version](https://badge.fury.io/rb/kbsecret.svg)](https://badge.fury.io/rb/kbsecret)
[![Build Status](https://travis-ci.org/kbsecret/kbsecret.svg?branch=master)](https://travis-ci.org/kbsecret/kbsecret)
[![Coverage Status](https://coveralls.io/repos/github/kbsecret/kbsecret/badge.svg)](https://coveralls.io/github/kbsecret/kbsecret?branch=coveralls)

KBSecret is a command line utility and library for managing *secrets*.

Quick links:

* [Installation instructions](https://kbsecret.github.io/installation)
* [Quick start guide](https://kbsecret.github.io/quickstart)
* [CLI documentation](https://kbsecret.github.io/man/)
* [API documentation](http://www.rubydoc.info/gems/kbsecret/)
* [Customizing your installation](https://kbsecret.github.io/customization)

## Hacking on KBSecret

Want to hack on KBSecret? Here's how you can get started:

```bash
$ git clone git@github.com:kbsecret/kbsecret.git && cd kbsecret
$ bundle install --path vendor/bundle
$ RUBYLIB=./lib PATH=./bin:${PATH} bundle exec ./bin/kbsecret help
```

### System Packages

You can also build (very experimental) installation packages:

```bash
$ bundle exec make deb # for apt/dpkg based systems
$ bundle exec make rpm # for yum/rpm based systems
$ bundle exec make pacman # for pacman based systems
$ ls pkg/{deb,rpm,pacman}/*
```

### Manual Pages

KBSecret's manual pages can be found online
[here](https://yossarian.net/docs/kbsecret-man/kbsecret.1).

If you'd like to generate the roff versions for `man(1)`, you'll need `ronn(1)`:

```bash
$ bundle exec make man
$ cp man/*.1 ${YOUR_MAN_DIR}
```

### Shell Completion

KBSecret provides shell completion functions for bash, zsh, and fish.

To generate the completions for Bash:

```bash
$ bundle exec make bash
$ # or, if you have additional commands that support --introspect-flags:
$ CMDS='foo bar baz' bundle exec make bash
$ cp completions/kbsecret.bash ${YOUR_COMPLETION_DIR}
```

To use the completions for zsh, add the completions directory to your `$fpath` or copy the
`completions/_kbsecret` file to any of the directories in it.

To use the fish completions, copy `completions/kbsecret.fish` to your `~/.config/fish/completions` folder.

Please feel free to contribute completion scripts for other shells!

### Contributing

See ["help wanted"](https://github.com/kbsecret/kbsecret/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22)
on the [issue tracker](https://github.com/kbsecret/kbsecret/issues).

If you have an idea for a new feature, please suggest it! Pull requests are also welcome.

### Community and Help

If you'd like help or would just like to chat about KBSecret's development, please
join us in `#kbsecret` on Freenode.

We also have a Keybase team. Please let us know on IRC if you'd like to be added to it.

## Licensing

KBSecret is licensed under the MIT License.

KBSecret's logo was created by [Arathnim](http://arathnim.me).
