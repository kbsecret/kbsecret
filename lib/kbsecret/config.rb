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

    # Configuration facets used for method generation.
    # @api private
    CONFIG_FACETS = {
      session: {
        plural: :sessions,
        except: SessionUnknownError,
      },

      generator: {
        plural: :generators,
        except: GeneratorUnknownError,
      },
    }.freeze

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

    # @!method session
    #   Retrieve a session's configuration.
    #   @param label [String, Symbol] the session's label
    #   @return [Hash] the session configuration
    #   @raise [SessionUnknownError] if no such session exists
    # @!method session_labels
    #   @return [Array<Symbol>] all configured session labels
    # @!method session?
    #   @param label [String, Symbol] the session label
    #   @return [Boolean] whether or not the given session is configured
    # @!method configure_session
    #   Configure a session.
    #   @param label [String, Symbol] the session label
    #   @param hsh [Hash] the session configuration
    #   @return [void]
    # @!method deconfigure_session
    #   Deconfigure a session.
    #   @param label [String, Symbol] the session label
    #   @return [void]
    #   @note This only removes the given session from the configuration, making
    #    it "invisible" to `kbsecret`. To actually remove all files associated
    #    with a session, see {KBSecret::Session#unlink!}.
    # @!method generator
    #   Retrieve a generator's configuration.
    #   @param gen [String, Symbol] the generator's label
    #   @return [Hash] the generator configuration
    #   @raise [GeneratorUnknownError] if no such generator exists
    # @!method generator_labels
    #   @return [Array<Symbol>] all configured session labels
    # @!method generator?
    #   @param gen [String, Symbol] the generator label
    #   @return [Boolean] whether or not the given generator is configured
    # @!method configure_generator
    #   Configure a secret generator.
    #   @param label [String, Symbol] the generator label (profile name)
    #   @param hsh [Hash] the generator configuration
    #   @return [void]
    # @!method deconfigure_generator
    #   Deconfigure a generator.
    #   @param label [String, Symbol] the generator label (profile name)
    #   @return [void]
    CONFIG_FACETS.each do |facet, data|
      define_singleton_method facet do |label|
        hsh = @config[data[:plural]][label.to_sym]

        raise data[:except], label unless hsh

        hsh
      end

      define_singleton_method "#{facet}_labels" do
        @config[data[:plural]].keys
      end

      define_singleton_method "#{facet}?" do |label|
        @config[data[:plural]].keys.include? label.to_sym
      end

      define_singleton_method "configure_#{facet}" do |label, **hsh|
        @config[data[:plural]][label.to_sym] = hsh
        sync!
      end

      define_singleton_method "deconfigure_#{facet}" do |label|
        @config[data[:plural]].delete(label.to_sym)
        sync!
      end
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
