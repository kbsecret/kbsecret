require "keybase"

require_relative "kbsecret/config"
require_relative "kbsecret/exceptions"
require_relative "kbsecret/record"
require_relative "kbsecret/session"

# The primary namespace for kbsecret.
module KBSecret
  # kbsecret's current version
  VERSION = "0.1.1".freeze

  # fail very early if the user doesn't have keybase and KBFS running
  raise Keybase::KeybaseNotRunningError unless Keybase.running?
  raise Keybase::KBFSNotRunningError unless Dir.exist?(Config[:mount])
end
