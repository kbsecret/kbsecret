# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start
elsif ENV["COVERALLS"]
  require "coveralls"
  Coveralls.wear!
end

require "yaml"
require "tmpdir"
require "fileutils"
require "securerandom"
require "minitest/autorun"

if ENV["TEST_NO_KEYBASE"]
  # back up the user's config, if it exists, so that we don't clobber it during testing
  conf_path = File.expand_path "~/.config/kbsecret/"
  FileUtils.mkdir_p conf_path

  conf_file = File.join conf_path, "config.yml"
  FileUtils.mv conf_file, "#{conf_file}.bak", force: true if File.file?(conf_file)

  dummy_config = { mount: Dir.mktmpdir }
  File.write conf_file, dummy_config.to_yaml

  require_relative "stub/keybase"
  require "keybase/api"
  require "kbsecret/exceptions"
  require "kbsecret/config"
  require "kbsecret/record"
  require "kbsecret/session"
  require "kbsecret/generator"
  require "kbsecret/cli"

  MiniTest.after_run do
    mnt = KBSecret::Config[:mount]
    # just to be extra certain we don't nuke the real KBFS
    FileUtils.rm_rf mnt unless mnt.start_with?("/keybase")

    # restore the original config, if one exists
    FileUtils.mv "#{conf_file}.bak", conf_file, force: true if File.file?("#{conf_file}.bak")
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
      users: [Keybase::Local.current_user],
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
