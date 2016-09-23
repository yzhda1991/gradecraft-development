class AddAwardedByIdToEarnedBadge < ActiveRecord::Migration
  def change
    add_column :earned_badges, :awarded_by_id, :integer
    add_foreign_key :earned_badges, :users, column: :awarded_by_id
  end
end
