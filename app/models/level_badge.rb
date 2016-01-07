class LevelBadge < ActiveRecord::Base
  belongs_to :level
  belongs_to :badge

  attr_accessible :level_id, :badge_id

  validates :level_id, uniqueness: { scope: :badge_id }

end
