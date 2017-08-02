# frozen_string_literal: true

require "simplecov"
SimpleCov.start if ENV["COVERAGE"]

require "fileutils"
require "securerandom"
require "minitest/autorun"

if ENV["TEST_NO_KEYBASE"]
  require_relative "stub/keybase"
  require "keybase/api"
  require "kbsecret/exceptions"
  require "kbsecret/config"
  require "kbsecret/record"
  require "kbsecret/session"
  require "kbsecret/generator"
  require "kbsecret/cli"

  MiniTest.after_run do
    mnt = Keybase::Configuration::KBFS_MOUNT
    # just to be extra certain we don't nuke the real KBFS
    FileUtils.rm_rf mnt unless mnt.start_with?("/keybase")
  end
else
  require "keybase"
  require "kbsecret"
end

# Helper methods for unit tests.
module Helpers
  def unique_label_and_session
    label = SecureRandom.hex(10).to_sym
    hsh = {
      users: [Keybase.current_user],
      root: SecureRandom.uuid,
    }

    [label, hsh]
  end

  def temp_session
    label, hsh = unique_label_and_session
    KBSecret::Config.configure_session(label, hsh)

    sess = KBSecret::Session.new label: label
    yield sess
  ensure
    sess&.unlink!
    KBSecret::Config.deconfigure_session(label)
  end

  def fake_argv(args)
    real_argv = ARGV.dup
    ARGV.replace args
    yield
    ARGV.replace real_argv
  end
end
