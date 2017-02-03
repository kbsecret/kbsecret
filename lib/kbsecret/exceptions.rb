module KBSecret
  class KBSecretError < RuntimeError
  end

  class RecordCreationArityError < RuntimeError
    def initialize(exp, act)
      super "Needed #{exp} arguments for this record, got #{act}"
    end
  end
end
