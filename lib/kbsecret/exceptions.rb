# frozen_string_literal: true

module KBSecret
  # A generic error in kbsecret.
  class KBSecretError < RuntimeError
  end

  # Raised during record creation if an unknown record type is requested.
  class RecordTypeUnknownError < KBSecretError
    def initialize(type)
      super "Unknown record type: #{type}"
    end
  end

  # Raised during record creation if too many/few arguments are given.
  class RecordCreationArityError < KBSecretError
    def initialize(exp, act)
      super "Needed #{exp} arguments for this record, got #{act}"
    end
  end
end
