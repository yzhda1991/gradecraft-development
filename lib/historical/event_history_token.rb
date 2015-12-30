class EventHistoryToken
  attr_reader :event

  def initialize(_, value, _)
    @event = value
  end

  def parse(options={})
    { self.class.token => event == "update" ? "changed" : "created" }
  end

  class << self
    def token
      :event
    end

    def tokenizable?(key, _, _)
      key == "event"
    end
  end
end
