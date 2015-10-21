class CleanUpBadges < ActiveRecord::Migration
  def change
    remove_column :badges, :badge_set_id
  end
end
