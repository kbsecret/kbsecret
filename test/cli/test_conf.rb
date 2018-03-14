# frozen_string_literal: true

require "helpers"

# tests cli command: list
class CLIConfTest < Minitest::Test
  include Aruba::Api
  include Helpers
  include Helpers::CLI

  def setup
    setup_aruba
  end

  def test_conf
    # with EDITOR unset, `kbsecret conf` should produce an error message
    delete_environment_variable "EDITOR"
    kbsecret "conf", interactive: false do |_, stderr|
      assert_match(/You need to set \$EDITOR/, stderr)
    end

    # with EDITOR set to `cat`, `kbsecret conf` should output the configuration
    set_environment_variable "EDITOR", "cat"
    kbsecret "conf", interactive: false do |stdout, _|
      assert_match(/:mount:/, stdout)
    end
  end
end
