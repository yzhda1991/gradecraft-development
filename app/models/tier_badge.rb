class TierBadge < ActiveRecord::Base
  belongs_to :tier, touch: true
  belongs_to :badge, touch: true

  attr_accessible :tier_id, :badge_id

  validates :tier_id, uniqueness: { scope: :badge_id }

  def self.delete_duplicates
    unique_ids = select("MIN(id) as id").group(:tier_id,:badge_id).collect(&:id)
    where.not(id: unique_ids).destroy_all
  end
end
