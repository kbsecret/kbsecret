# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI.
class KBSecretCLITest < Minitest::Test
  include Helpers
  include Helpers::CLI

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
      verbose?: %w[-V --verbose],
      no_warn?: %w[-w --no-warn],
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
    # first, test session assurance via the --session flag
    fake_argv %w[--session default] do
      cmd = KBSecret::CLI.create do |c|
        c.slop do |o|
          o.string "-s", "--session", "the session to search in"
        end

        c.ensure_session!
      end

      # cmd should be instantiated, and cmd.session should be set to the argv-specified session
      assert_instance_of KBSecret::CLI, cmd
      assert_instance_of KBSecret::Session, cmd.session
      assert_equal :default, cmd.session.label
    end

    # the default slop value should pick up the slack for us, if we don't specify
    # the session explicitly
    fake_argv [] do
      cmd = KBSecret::CLI.create do |c|
        c.slop do |o|
          o.string "-s", "--session", "the session to search in", default: :default
        end

        c.ensure_session!
      end

      # cmd should be instantiated, and cmd.session should be set to the argv-specified session
      assert_instance_of KBSecret::CLI, cmd
      assert_instance_of KBSecret::Session, cmd.session
      assert_equal :default, cmd.session.label
    end

    # session assurance should also work for a trailing argument parsed by dreck
    fake_argv %w[default] do
      cmd = KBSecret::CLI.create do |c|
        c.slop { |_o| nil }

        c.dreck do
          string :session
        end

        c.ensure_session! :argument
      end

      # cmd should be instantiated, and cmd.session should be set to the argv-specified session
      assert_instance_of KBSecret::CLI, cmd
      assert_instance_of KBSecret::Session, cmd.session
      assert_equal :default, cmd.session.label
    end
  end

  def test_cli_ensure_type
    # first, test type assurance via the --type flag
    fake_argv %w[--type login] do
      cmd = KBSecret::CLI.create do |c|
        c.slop do |o|
          o.string "-t", "--type", "the type"
        end

        c.ensure_type!
      end

      # cmd should be instantiated, and the type passed in ARGV should be a valid KBSecret type
      assert_instance_of KBSecret::CLI, cmd
      assert KBSecret::Record.type?(cmd.opts[:type])
    end

    # the default slop value should pick up the slack for us, if we don't specify
    # the type explicitly
    fake_argv [] do
      cmd = KBSecret::CLI.create do |c|
        c.slop do |o|
          o.string "-t", "--type", "the type", default: "login"
        end

        c.ensure_type!
      end

      # cmd should be instantiated, and the type passed in ARGV should be a valid KBSecret type
      assert_instance_of KBSecret::CLI, cmd
      assert KBSecret::Record.type?(cmd.opts[:type])
    end

    # type assurance should also work for a trailing argument parsed by dreck
    fake_argv %w[login] do
      cmd = KBSecret::CLI.create do |c|
        c.slop { |_o| nil }

        c.dreck do
          string :type
        end

        c.ensure_type! :argument
      end

      # cmd should be instantiated, and the type passed in ARGV should be a valid KBSecret type
      assert_instance_of KBSecret::CLI, cmd
      assert KBSecret::Record.type?(cmd.args[:type])
    end
  end

  def test_cli_ensure_generator
    skip
  end

  def test_cli_io
    assert_instance_of IO, KBSecret::CLI.stdin
    assert_instance_of IO, KBSecret::CLI.stdout
    assert_instance_of IO, KBSecret::CLI.stderr

    stdout, stderr = fork_capture_io do
      KBSecret::CLI.stdout.puts "some junk on stdout"
      KBSecret::CLI.stderr.puts "some junk on stderr"
    end

    assert_match "some junk on stdout", stdout
    assert_match "some junk on stderr", stderr
  end

  def test_cli_info_output
    cmd = KBSecret::CLI.create [] do |c|
      c.slop { |_o| nil }
    end

    _, stderr = fork_capture_io do
      cmd.info "informational message"
    end

    assert_match "informational message", stderr
  end

  def test_cli_verbose_output
    cmd = KBSecret::CLI.create [] do |c|
      c.slop { |_o| nil }
    end

    _, stderr = fork_capture_io do
      cmd.verbose "verbose message"
    end

    # without --verbose, the verbose message shouldn't be printed
    assert_empty stderr

    cmd = KBSecret::CLI.create %w[--verbose] do |c|
      c.slop { |_o| nil }
    end

    _, stderr = fork_capture_io do
      cmd.verbose "verbose message"
    end

    assert_match "verbose message", stderr
  end

  def test_cli_warn_output
    cmd = KBSecret::CLI.create %w[--no-warn] do |c|
      c.slop { |_o| nil }
    end

    _, stderr = fork_capture_io do
      cmd.warn "warning message"
    end

    # with --no-warn, the warning message shouldn't be printed
    assert_empty stderr

    cmd = KBSecret::CLI.create [] do |c|
      c.slop { |_o| nil }
    end

    _, stderr = fork_capture_io do
      cmd.warn "warning message"
    end

    assert_match "warning message", stderr
  end

  def test_cli_die_output
    cmd = KBSecret::CLI.create [] do |c|
      c.slop { |_o| nil }
    end

    _, stderr = fork_capture_io do
      cmd.die "fatal message"
    end

    assert_match "fatal message", stderr

    # the class method should behave identically
    _, stderr = fork_capture_io do
      KBSecret::CLI.die "fatal message"
    end

    assert_match "fatal message", stderr
  end
end
