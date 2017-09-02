# frozen_string_literal: true

require "keybase"

require_relative "version"
require_relative "kbsecret/exceptions"
require_relative "kbsecret/config"
require_relative "kbsecret/record"
require_relative "kbsecret/session"
require_relative "kbsecret/generator"
require_relative "kbsecret/cli"

# The primary namespace for {KBSecret}.
module KBSecret
  # fail very early if the user doesn't have keybase and KBFS running
  raise Keybase::Exceptions::KeybaseNotRunningError unless Keybase.running?
  raise Keybase::Exceptions::KBFSNotRunningError unless Dir.exist?(Keybase::Config::KBFS_MOUNT)
end
