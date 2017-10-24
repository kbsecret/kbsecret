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
  def self.kbfs_logged_in
    begin
      return false if JSON.parse(File.read(File.join(Config[:mount], ".kbfs_status")))["CurrentUser"].empty?
    rescue
      return false
    end
    return true
  end
  # fail very early if the user doesn't have keybase and KBFS running
  raise Keybase::Local::Exceptions::KeybaseNotRunningError unless Keybase::Local.running?
  JSON.parse(File.read(File.join(Config[:mount], ".kbfs_status")))
  raise Keybase::Local::Exceptions::KBFSNotRunningError unless File.exist?(File.join(Config[:mount], ".kbfs_status"))
  raise Exceptions::KBSecretError.new("Keybase not logged in") unless self.kbfs_logged_in()
end
