module ScoreLevel
  extend ActiveSupport::Concern

  included do
    attr_accessible :name, :value

    scope :order_by_value, -> { order 'value DESC' }

    validates :name, presence: true
    validates :value, presence: true
  end
end
