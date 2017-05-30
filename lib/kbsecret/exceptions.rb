# frozen_string_literal: true

module KBSecret
  # A generic error in kbsecret.
  class KBSecretError < RuntimeError
  end

  # Raised during record creation if too many/few arguments are given.
  class RecordCreationArityError < RuntimeError
    def initialize(exp, act)
      super "Needed #{exp} arguments for this record, got #{act}"
    end
  end
end
