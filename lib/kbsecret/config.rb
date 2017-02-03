require "yaml"
require "fileutils"

module KBSecret
  class Config
    CONFIG_DIR = File.expand_path("~/.config/kbsecret").freeze

    CONFIG_FILE = File.join(CONFIG_DIR, "config.yml").freeze

    DEFAULT_CONFIG = {
      mount: "/keybase",

      sessions: {
        default: {
          users: [Keybase.current_user],
          root: "kbsecret",
        }
      }
    }.freeze

    def self.[](key)
      @@config[key]
    end

    def self.session(sess)
      @@config[:sessions][sess]
    end

    def self.session_names
      @@config[:sessions].keys
    end

    def self.session?(sess)
      session_names.include?(sess.to_sym)
    end

    def self.add_session(label, hsh)
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
