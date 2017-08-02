# frozen_string_literal: true

require_relative "helpers"

class KBSecretCLITest < Minitest::Test
  include Helpers

  def test_cli_default_options
    fake_argv [] do
      cmd = KBSecret::CLI.create do |c|
        # slop needs to be called to populate the default options
        c.slop { |_o| nil }
      end

      # create should return a CLI instance
      assert_instance_of KBSecret::CLI, cmd

      # ...and all of the default options should be false
      refute cmd.opts.verbose?
      refute cmd.opts.no_warn?
      refute cmd.opts.help?
      refute cmd.opts.introspect_flags?
    end

    flag_map = {
      verbose?: ["-V", "--verbose"],
      no_warn?: ["-w", "--no-warn"],
      # XXX: figure out how to test these, since they produce output
      # help?: ["-h", "--help"],
      # introspect_flags?: ["--introspect-flags"],
    }

    # when present, each default option/switch should toggle its method
    flag_map.each do |meth, flags|
      flags.each do |flag|
        fake_argv [flag] do
          cmd = KBSecret::CLI.create do |c|
            c.slop { |_o| nil }
          end

          # create should return a CLI instance
          assert_instance_of KBSecret::CLI, cmd

          # the one present flag/switch should toggle
          assert cmd.opts.send(meth)

          # ...and the rest should be false
          (flag_map.keys - [meth]).each do |missing|
            refute cmd.opts.send(missing)
          end
        end
      end
    end
  end

  def test_cli_trailing_arguments
    fake_argv %w[foo bar baz] do
      # no options are specified to take arguments and no dreck block is defined,
      # so trailing arguments should be present in slop's result
      cmd = KBSecret::CLI.create do |c|
        c.slop { |_o| nil }
      end

      # cmd should be instantiated, and slop's result should contain
      # the trailing arguments, unmodified
      assert_instance_of KBSecret::CLI, cmd
      assert_instance_of Array, cmd.opts.args
      assert_equal %w[foo bar baz], cmd.opts.args

      # ...but dreck's args should *not* be instantiated
      assert_nil cmd.args
    end
  end

  def test_cli_ensure_session
    skip
  end

  def test_cli_ensure_type
    skip
  end

  def test_cli_ensure_generator
    skip
  end
end
