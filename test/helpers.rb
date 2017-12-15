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
  # Helper methods for CLI unit tests.
  module CLI
    def kbsecret(args, interactive: true)
      if interactive
        run_command "kbsecret #{args}" do |cmd|
          yield cmd if block_given?
          cmd.stdin&.close
          cmd.wait
        end
      else
        cmd = run_command "kbsecret #{args}"
        cmd.wait
        yield cmd.stdout, cmd.stderr if block_given?
      end
    rescue StandardError => e
      raise e
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

    def create_test_records(types: [], number: 2, session: "default")
      list = []

      types = KBSecret::Record.record_types.map(&:to_s) if types.empty?

      types.each do |type|
        number.times do |i|
          label = "#{type}#{i}"
          list << label

          case type
          when "environment"
            params = "variable#{i}:value#{i}"
          when "login"
            params = "username#{i}:password#{i}"
          when "snippet"
            params = "code#{i}:description#{i}"
          when "todo"
            params = "todo#{i}"
          when "unstructured"
            params = "text#{i}"
          else
            # can't create an unknown or custom type
            p "unable to create #{type} records"
            next
          end

          # create record:
          kbsecret "new #{type} -s #{session} -x #{label}" do |cmd|
            cmd.stdin.puts params
          end
        end
      end
      # return the list of records to use for expectation checking
      list
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
