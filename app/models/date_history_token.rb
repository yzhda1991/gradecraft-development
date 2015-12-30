class DateHistoryToken
  attr_reader :datetime

  def initialize(_, value, _)
    @datetime = value.last
  end

  def parse(options={})
    { self.class.token => datetime.strftime("%B #{datetime.day.ordinalize}, %Y") }
  end

  class << self
    def token
      :date
    end

    def tokenizable?(key, _, _)
      key == "updated_at"
    end
  end
end
