# frozen_string_literal: true

require "fileutils"
require "inih"
require "shellwords"
require "yaml"

module KBSecret
  # Global and per-session configuration for kbsecret.
  class Config
    # The configuration directory.
    # @api private
    CONFIG_DIR = File.join(Keybase::Local.private_dir, "kbsecret/.config").freeze

    # The configuration file.
    # @api private
    CONFIG_FILE = File.join(CONFIG_DIR, "config.yml").freeze

    # The command configuration file.
    # @api private
    COMMAND_CONFIG_FILE = File.join(CONFIG_DIR, "commands.ini").freeze

    # The directory searched for custom record types.
    # @api private
    CUSTOM_TYPES_DIR = File.join(CONFIG_DIR, "record").freeze

    # Configuration facets used for method generation.
    # @api private
    CONFIG_FACETS = {
      session: {
        plural: :sessions,
        except: Exceptions::SessionUnknownError,
      },

      generator: {
        plural: :generators,
        except: Exceptions::GeneratorUnknownError,
      },
    }.freeze

    # The default session configuration.
    DEFAULT_SESSION = {
      default: {
        users: [Keybase::Local.current_user],
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
      mount: Keybase::Local::Config::KBFS_MOUNT,
      sessions: DEFAULT_SESSION.dup,
      generators: DEFAULT_GENERATOR.dup,
    }.freeze

    # Reads the user's configuration files from disk, introducing default values as necessary.
    # @return [void]
    # @api private
    def self.load!
      user_config = if File.exist?(CONFIG_FILE)
                      YAML.load_file(CONFIG_FILE)
                    else
                      DEFAULT_CONFIG
                    end

      @command_config = if File.exist?(COMMAND_CONFIG_FILE)
                          INIH.load(COMMAND_CONFIG_FILE)
                        else
                          {}
                        end

      @config = DEFAULT_CONFIG.merge(user_config)
      @config[:sessions].merge!(DEFAULT_SESSION)
      @config[:generators].merge!(DEFAULT_GENERATOR)
    end

    # Writes the user's configuration to disk.
    # @return [void]
    def self.sync!
      File.write(CONFIG_FILE, @config.to_yaml)
    end

    # Retrieve a configured value.
    # @param key [String] the configuration key to retrieve
    # @return [Object] the corresponding configuration
    def self.[](key)
      @config[key]
    end

    # Fetch the configuration for a `kbsecret` command.
    # @param cmd [String] the short name of the command
    # @return [Hash, nil] the command's configuration
    # @example
    #  # retrieves the config for `kbsecret-list`
    #  Config.command("list") # => { "args" => "...",  }
    def self.command(cmd)
      @command_config[cmd]
    end

    # Fetch the configured default arguments for a `kbsecret` command.
    # @param cmd [String] the short name of the command
    # @return [Array] the command's default arguments
    # @note Default arguments are split according to normal shell splitting rules.
    # @example
    #  Config.command_args("list") # => ["--show-all"]
    def self.command_args(cmd)
      @command_config.dig(cmd, "args")&.shellsplit || []
    end

    # Attempt to resolve an alias into a `kbsecret` command.
    # @param acmd [String] the command alias
    # @return [String] the `kbsecret` command, or `acmd` if the alias does not exist
    # @example
    #  Config.unalias_command("l") # => "list"
    #  Config.unalias_command("madeup") # => "madeup"
    def self.unalias_command(acmd)
      @command_config.each do |cmd, conf|
        aliases = conf["aliases"]&.split || []
        return cmd if aliases.include?(acmd)
      end

      acmd
    end

    # @!method session(label)
    #   Retrieve a session's configuration.
    #   @param label [String, Symbol] the session's label
    #   @return [Hash] the session configuration
    #   @raise [Exceptions::SessionUnknownError] if no such session exists
    # @!method session_labels
    #   @return [Array<Symbol>] all configured session labels
    # @!method session?(label)
    #   @param label [String, Symbol] the session label
    #   @return [Boolean] whether or not the given session is configured
    # @!method configure_session(label, hsh)
    #   Configure a session.
    #   @param label [String, Symbol] the session label
    #   @param hsh [Hash] the session configuration
    #   @return [void]
    # @!method deconfigure_session(label)
    #   Deconfigure a session.
    #   @param label [String, Symbol] the session label
    #   @return [void]
    #   @note This only removes the given session from the configuration, making
    #    it "invisible" to `kbsecret`. To actually remove all files associated
    #    with a session, see {KBSecret::Session#unlink!}.
    # @!method generator(label)
    #   Retrieve a generator's configuration.
    #   @param label [String, Symbol] the generator's label
    #   @return [Hash] the generator configuration
    #   @raise [Exceptions::GeneratorUnknownError] if no such generator exists
    # @!method generator_labels
    #   @return [Array<Symbol>] all configured session labels
    # @!method generator?(label)
    #   @param label [String, Symbol] the generator label
    #   @return [Boolean] whether or not the given generator is configured
    # @!method configure_generator(label, hsh)
    #   Configure a secret generator.
    #   @param label [String, Symbol] the generator label (profile name)
    #   @param hsh [Hash] the generator configuration
    #   @return [void]
    # @!method deconfigure_generator(label)
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

    FileUtils.mkdir_p CONFIG_DIR
    FileUtils.mkdir_p CUSTOM_TYPES_DIR

    load!
    sync!
  end
end
