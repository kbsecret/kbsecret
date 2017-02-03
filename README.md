kbsecret
========

*Note*: This is still a work in process. Use it with caution.

kbsecret is a combined library/utility that provides a secret management
interface for [KBFS](https://keybase.io/docs/kbfs) and
[Keybase](https://keybase.io/).

### Benefits over current offerings

* Easy password and environment sharing across multiple users.
  - `kbsecret -s dev-team login github` prints the dev team's GitHub login.
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
$ RUBYLIB=./lib PATH=./bin:${PATH} ./bin/kbsecret help
```

### Usage

```bash
# create a new login record under the default session
$ kbsecret new login gmail "foo@example.com" "barbazquux"

# list all records under the default session
$ kbsecret list
gmail

# show the requested login record
$ kbsecret login gmail
Label: gmail
	Username: foo@example.com
	Password: barbazquux

# create a new session between 3 keybase users (foo, bar, and baz)
$ kbsecret new-session -l dev-team -u foo,bar,baz

# list available sessions
$ kbsecret sessions
default
dev-team

# add an environment record to the dev-team session
$ kbsecret new environment API_KEY 0xBADBEEF -s dev-team

# list all records under the dev-team session
$ kbsecret list -s dev-team
API_KEY

# get all environment records in dev-team in an easy-to-source format
$ kbsecret env -s dev-team --all
export API_KEY='0xBADBEEF'
```
