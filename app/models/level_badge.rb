class LevelBadge < ActiveRecord::Base
  belongs_to :level
  belongs_to :badge

  validates :level_id, uniqueness: { scope: :badge_id }
end
