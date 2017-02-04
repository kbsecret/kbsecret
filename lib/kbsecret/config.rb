require "yaml"
require "fileutils"

module KBSecret
  # Global and per-session configuration for kbsecret.
  class Config
    # the configuration directory
    # @api private
    CONFIG_DIR = File.expand_path("~/.config/kbsecret").freeze

    # the configuration file
    # @api private
    CONFIG_FILE = File.join(CONFIG_DIR, "config.yml").freeze

    # configuration defaults
    # @api private
    DEFAULT_CONFIG = {
      mount: "/keybase",

      sessions: {
        default: {
          users: [Keybase.current_user],
          root: "kbsecret",
        }
      }
    }.freeze

    # Retrieve a configured value.
    # @param key [String]
    # @return [Object] the corresponding configuration
    def self.[](key)
      @@config[key]
    end

    # Retrieve a session's configuration.
    # @param sess [Symbol] the session's label
    # @return [Hash] the session configuration
    def self.session(sess)
      @@config[:sessions][sess]
    end

    # @return [Array<Symbol>] all configured session labels
    def self.session_labels
      @@config[:sessions].keys
    end

    # @param sess [Symbol] the session label
    # @return [Boolean] whether or not the given session is configured
    def self.session?(sess)
      session_labels.include?(sess.to_sym)
    end

    # Configure a session.
    # @param label [Symbol] the session label
    # @param hsh [Hash] the session configuration
    def self.configure_session(label, hsh)
      @@config[:sessions][label.to_sym] = hsh
      File.open(CONFIG_FILE, "w") { |io| io.write @@config.to_yaml }
    end

    if File.exist?(CONFIG_FILE)
      user_config = YAML.load_file(CONFIG_FILE)
    else
      user_config = DEFAULT_CONFIG
      FileUtils.mkdir_p CONFIG_DIR
      File.open(CONFIG_FILE, "w") { |io| io.write DEFAULT_CONFIG.to_yaml }
    end

    @@config = DEFAULT_CONFIG.merge(user_config)
  end
end
