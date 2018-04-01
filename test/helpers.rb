# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.merge_timeout(3600)

  pid = Process.pid
  SimpleCov.at_exit do
    SimpleCov.result.format! if Process.pid == pid
  end

  SimpleCov.start
end

require "yaml"
require "tmpdir"
require "fileutils"
require "securerandom"
require "minitest/autorun"

require "keybase"
require "kbsecret"

# Helper methods for unit tests.
module Helpers
  # Helper methods for CLI unit tests.
  module CLI
    def kbsecret(cmd, *args, input: "")
      pipes = {
        stdin: IO.pipe,
        stdout: IO.pipe,
        stderr: IO.pipe,
      }

      pipes[:stdin][1].puts input

      fork do
        if ENV["COVERAGE"]
          SimpleCov.command_name SecureRandom.uuid
          SimpleCov.start
        end

        # child: close the stdin writer, and stdout/stdin readers
        pipes[:stdin][1].close
        pipes[:stdout][0].close
        pipes[:stderr][0].close

        $stdin = pipes[:stdin][0]
        $stdout = pipes[:stdout][1]
        $stderr = pipes[:stderr][1]

        KBSecret::CLI::Command.run!(cmd, *args)
      end

      # parent: close the stdin reader/writer, and stdout/stderr writers
      pipes[:stdin][0].close
      pipes[:stdin][1].close
      pipes[:stdout][1].close
      pipes[:stderr][1].close

      Process.wait

      [pipes[:stdout][0].read, pipes[:stderr][0].read]
    end
  end

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
