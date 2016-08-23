module ScoreLevel
  extend ActiveSupport::Concern
  include Copyable

  included do
    scope :order_by_points, -> { order "points DESC" }

    validates :name, presence: true
    validates :points, presence: true
  end

  # Displaying the name and the points together in grading lists
  def formatted_name
    "#{name} (#{points} points)"
  end
end
