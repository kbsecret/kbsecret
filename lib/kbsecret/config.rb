# frozen_string_literal: true

require "yaml"
require "fileutils"

module KBSecret
  # Global and per-session configuration for kbsecret.
  class Config
    # The configuration directory.
    # @api private
    CONFIG_DIR = File.expand_path("~/.config/kbsecret").freeze

    # The configuration file.
    # @api private
    CONFIG_FILE = File.join(CONFIG_DIR, "config.yml").freeze

    # The default session configuration.
    DEFAULT_SESSION = {
      default: {
        users: [Keybase.current_user],
        root: "default",
      },
    }.freeze

    # The default generator configuration.
    DEFAULT_GENERATOR = {
      default: {
        format: "hex",
        length: 16,
      },
    }.freeze

    # configuration defaults
    # @api private
    DEFAULT_CONFIG = {
      session_root: File.join("/keybase/private/",
                              Keybase.current_user,
                              "kbsecret"),

      mount: "/keybase",
      sessions: DEFAULT_SESSION,
      generators: DEFAULT_GENERATOR,
    }.freeze

    # Writes the user's configuration to disk.
    # @return [void]
    def self.sync!
      File.open(CONFIG_FILE, "w") { |io| io.write @config.to_yaml }
    end

    # Retrieve a configured value.
    # @param key [String] the configuration key to retrieve
    # @return [Object] the corresponding configuration
    def self.[](key)
      @config[key]
    end

    # Retrieve a session's configuration.
    # @param sess [String, Symbol] the session's label
    # @return [Hash] the session configuration
    # @raise [SessionUnknownError] if no such session exists
    def self.session(sess)
      hsh = @config[:sessions][sess.to_sym]

      raise SessionUnknownError, sess unless hsh

      hsh
    end

    # @return [Array<Symbol>] all configured session labels
    def self.session_labels
      @config[:sessions].keys
    end

    # @param sess [String, Symbol] the session label
    # @return [Boolean] whether or not the given session is configured
    def self.session?(sess)
      session_labels.include?(sess.to_sym)
    end

    # Configure a session.
    # @param label [String, Symbol] the session label
    # @param hsh [Hash] the session configuration
    # @return [void]
    def self.configure_session(label, hsh)
      @config[:sessions][label.to_sym] = hsh
      sync!
    end

    # Deconfigure a session.
    # @param label [String, Symbol] the session label
    # @return [void]
    # @note This only removes the given session from the configuration, making
    #  it "invisible" to `kbsecret`. To actually remove all files associated
    #  with a session, see {KBSecret::Session#unlink!}.
    def self.deconfigure_session(label)
      @config[:sessions].delete(label.to_sym)
      sync!
    end

    # Retrieve a generator's configuration.
    # @param gen [String, Symbol] the generator's label
    # @return [Hash] the generator configuration
    # @raise [GeneratorUnknownError] if no such generator exists
    def self.generator(gen)
      hsh = @config[:generators][gen.to_sym]

      raise GeneratorUnknownError, gen unless hsh

      hsh
    end

    # @return [Array<Symbol>] all configured session labels
    def self.generator_labels
      @config[:generators].keys
    end

    # @param gen [String, Symbol] the generator label
    # @return [Boolean] whether or not the given generator is configured
    def self.generator?(gen)
      generator_labels.include?(gen.to_sym)
    end

    # Configure a secret generator.
    # @param label [String, Symbol] the generator label (profile name)
    # @param hsh [Hash] the generator configuration
    # @return [void]
    def self.configure_generator(label, **hsh)
      @config[:generators][label.to_sym] = hsh
      sync!
    end

    # Deconfigure a generator.
    # @param label [String, Symbol] the generator label (profile name)
    # @return [void]
    def self.deconfigure_generator(label)
      @config[:generators].delete(label.to_sym)
      sync!
    end

    if File.exist?(CONFIG_FILE)
      user_config = YAML.load_file(CONFIG_FILE)
    else
      user_config = DEFAULT_CONFIG
      FileUtils.mkdir_p CONFIG_DIR
    end

    @config = DEFAULT_CONFIG.merge(user_config)
    @config[:sessions].merge!(DEFAULT_SESSION)
    @config[:generators].merge!(DEFAULT_GENERATOR)

    FileUtils.mkdir_p @config[:session_root]
    sync!
  end
end
