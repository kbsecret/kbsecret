# frozen_string_literal: true

require "helpers"

# tests cli command: generators
class CLIGeneratorsTest < Minitest::Test
  include Aruba::Api
  include Helpers
  include Helpers::CLI

  def setup
    setup_aruba
  end

  def test_generators
    # NOTE: testing user may have more than the default generator,
    # so our patterns will need to accommodate this possibility
    pattern = /default/
    # retrieve generators:
    kbsecret "generators", interactive: false do |stdout, _|
      assert_match pattern, stdout
    end
  end

  def test_generators_show_all
    pattern = /default\n\tFormat: hex\n\tLength: 16/

    # retrieve generators:
    kbsecret "generators -a", interactive: false do |stdout, _|
      assert_match pattern, stdout
    end
  end

  def test_generators_added
    label = "test-generator"
    pattern = /default.*#{label}|#{label}.*default/m

    # add generator
    kbsecret "generator new #{label} -F hex -l 64"

    # retrieve generators:
    kbsecret "generators", interactive: false do |stdout, _|
      assert_match pattern, stdout
    end
  ensure
    # remove generator
    kbsecret "generator rm #{label}"
  end

  def test_generators_added_show_all
    label = "test-generator"
    format = "base64"
    length = "64"
    test_detail = /#{label}\n\tFormat: #{format}\n\tLength: #{length}/
    default_detail = /default\n\tFormat: hex\n\tLength: 16/
    pattern = /#{default_detail}.*#{test_detail}|#{test_detail}.*#{default_detail}/m

    # add generator
    kbsecret "generator new #{label} -F #{format} -l #{length}"

    # retrieve generators:
    kbsecret "generators -a", interactive: false do |stdout, _|
      assert_match pattern, stdout
    end
  ensure
    # remove generator
    kbsecret "generator rm #{label}"
  end

  def test_generators_unknown_option
    error_pattern = /Unknown option/

    # retrieve generators:
    kbsecret "generators -x", interactive: false do |_, stderr|
      assert_match error_pattern, stderr
    end
  end
end
