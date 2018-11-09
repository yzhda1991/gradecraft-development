class AddAutoAwardAfterUnlockToBadges < ActiveRecord::Migration[5.0]
  def change
    add_column :badges, :auto_award_after_unlock, :boolean
  end
end
