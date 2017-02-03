require "keybase"

require_relative "kbsecret/config"
require_relative "kbsecret/exceptions"
require_relative "kbsecret/record"
require_relative "kbsecret/session"

module KBSecret
  VERSION = "0.0.1".freeze

  raise Keybase::KeybaseNotRunningError unless Keybase.running?
  raise Keybase::KBFSNotRunningError unless Dir.exist?(Config[:mount])
end
