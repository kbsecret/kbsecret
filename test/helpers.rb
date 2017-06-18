# frozen_string_literal: true

require "securerandom"
require "keybase"
require "kbsecret"

module Helpers
  def unique_label_and_session
    label = SecureRandom.hex(10).to_sym
    hsh = {
      users: [Keybase.current_user],
      root: SecureRandom.uuid,
    }

    [label, hsh]
  end

  def temp_session
    label, hsh = unique_label_and_session
    KBSecret::Config.configure_session(label, hsh)

    sess = KBSecret::Session.new label: label
    yield sess
  ensure
    sess&.unlink!
    KBSecret::Config.deconfigure_session(label)
  end
end
