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
  # fail very early if the user doesn't have Keybase running and KBFS mounted
  raise Keybase::Local::Exceptions::KBFSNotRunningError unless Keybase::Local::KBFS.mounted?
end
