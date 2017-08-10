KBSecret
========

[![Gem Version](https://badge.fury.io/rb/kbsecret.svg)](https://badge.fury.io/rb/kbsecret)
[![Build Status](https://travis-ci.org/woodruffw/kbsecret.svg?branch=master)](https://travis-ci.org/woodruffw/kbsecret)
[![Coverage Status](https://coveralls.io/repos/github/woodruffw/kbsecret/badge.svg?branch=master)](https://coveralls.io/github/woodruffw/kbsecret?branch=master)

*Note*: This is still a work in process. Use it with caution.

KBSecret is a combined library/utility that provides a secret management
interface for [KBFS](https://keybase.io/docs/kbfs) and
[Keybase](https://keybase.io/).

### Benefits over current offerings

* Easy password and environment sharing across multiple users.
  - `kbsecret login -s dev-team github` prints the dev team's GitHub login.
* No PGP/SSH key setup necessary - you only need a Keybase account.
  - No more worrying about losing your key.
* Transparent access - KBFS provides a VFS layer over all reads/writes.
  - All records are stored encrypted on KBFS.

### Installation

KBSecret is available via [RubyGems](https://rubygems.org/gems/kbsecret):

```bash
$ gem install kbsecret

# or, install the latest prerelease:

$ gem install --pre kbsecret
```

For hacking:

```bash
$ git clone git@github.com:woodruffw/kbsecret.git && cd kbsecret
$ bundle install --path vendor/bundle
$ RUBYLIB=./lib PATH=./bin:${PATH} bundle exec ./bin/kbsecret help
```

You can also build (very experimental) installation packages:

```bash
$ bundle exec make deb # for apt/dpkg based systems
$ bundle exec make rpm # for yum/rpm based systems
$ bundle exec make pacman # for pacman based systems
$ ls pkg/{deb,rpm,pacman}/*
```

Documentation is available on [RubyDoc](http://www.rubydoc.info/gems/kbsecret/).

### Usage

```bash
# create a new login record under the default session
$ kbsecret new login gmail
Username? bob@gmail.com
Password?

# list all records under the default session
$ kbsecret list
gmail

# show the requested login record
$ kbsecret login gmail
Label: gmail
	Username: bob@gmail.com
	Password: barbazquux

# create a new session between 3 keybase users (foo, bar, and baz)
$ kbsecret new-session -l dev-team -u foo,bar,baz

# list available sessions
$ kbsecret sessions
default
dev-team

# add an environment record to the dev-team session
$ kbsecret new environment api-key -s dev-team
Variable? BRAND_NEW_API
Value?

# list all records under the dev-team session
$ kbsecret list -s dev-team
api-key

# get all environment records in dev-team in an easy-to-source format
$ kbsecret env -s dev-team --all
export BRAND_NEW_API='0xBADBEEF'
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

KBSecret provides shell completion functions for bash.

To generate them:

```bash
$ bundle exec make bash
$ # or, if you have additional commands that support --introspect-flags:
$ CMDS='foo bar baz' bundle exec make bash
$ cp completions/kbsecret.bash ${YOUR_COMPLETION_DIR}
```

Please feel free to contribute completion scripts for other shells!

### Contributing

See ["help wanted"](https://github.com/woodruffw/kbsecret/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22)
on the [issue tracker](https://github.com/woodruffw/kbsecret/issues).

If you have an idea for a new feature, please suggest it! Pull requests are also welcome.

### Community and Help

If you'd like help or would just like to chat about KBSecret's development, please
join us in `#kbsecret` on Freenode.
