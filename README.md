kbsecret
========

[![Gem Version](https://badge.fury.io/rb/kbsecret.svg)](https://badge.fury.io/rb/kbsecret)

*Note*: This is still a work in process. Use it with caution.

kbsecret is a combined library/utility that provides a secret management
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

kbsecret is available via [RubyGems](https://rubygems.org/gems/kbsecret):

```bash
$ gem install kbsecret
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

kbsecret's manual pages can be found online
[here](https://yossarian.net/docs/kbsecret-man/kbsecret.1).

If you'd like to generate the roff versions for `man(1)`, you'll need `ronn(1)`:

```bash
$ bundle exec make man
$ cp man/*.1 ${YOUR_MAN_DIR}
```

### Shell Completion

kbsecret provides shell completion functions for bash.

To generate them:

```bash
$ bundle exec make bash
$ # or, if you have additional commands that support --introspect-flags:
$ CMDS='foo bar baz' bundle exec make bash
$ cp completions/kbsecret.bash ${YOUR_COMPLETION_DIR}
```

Please feel free to contribute completion scripts for other shells!

### TODO

* zsh/fish completions
* facility for moving sessions (add users, change session label, etc)
* glob for available sessions instead of requiring explicit configuration
* unit tests for command-line utilities
