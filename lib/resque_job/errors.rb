module ResqueJob
  class ForcedRetryError < StandardError
    def initialize(message="Deliberately raised and error after catching an exception to trigger resque-retry for this Job.")
      super(message)
    end
  end
end
