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
require "aruba/api"

require "keybase"
require "kbsecret"

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

  def generator_regexp(format: :hex, length: 16)
    case format
    when "hex"
      output = length * 2
      /\h{#{output}}/
    else # base64
      output = ((4 * length / 3) + 3) & ~3
      /[a-zA-Z0-9+\/=]{#{output}}/
    end
  end
end
