# frozen_string_literal: true

require "keybase"

# fail very early if the user's KBFS installation isn't fully functional
raise Keybase::Local::Exceptions::KBFSNotRunningError unless Keybase::Local::KBFS.functional?

require_relative "kbsecret/version"
require_relative "kbsecret/exceptions"
require_relative "kbsecret/config"
require_relative "kbsecret/record"
require_relative "kbsecret/session"
require_relative "kbsecret/generator"
require_relative "kbsecret/cli"

# The primary namespace for {KBSecret}.
module KBSecret
end
