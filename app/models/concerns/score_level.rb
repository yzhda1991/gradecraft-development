module ScoreLevel
  extend ActiveSupport::Concern

  included do
    attr_accessible :name, :value

    scope :order_by_value, -> { order 'value DESC' }

    validates :name, presence: true
    validates :value, presence: true
  end
  
  #Displaying the name and the point value together in grading lists
  def formatted_name
    "#{name} (#{value} points)"
  end

  def copy
    self.dup
  end

end
