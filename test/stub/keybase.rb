require "tmpdir"

module Keybase
  def self.current_user
    "dummy"
  end

  class U
    def self.[](*args)
      args.join(",")
    end
  end
end
