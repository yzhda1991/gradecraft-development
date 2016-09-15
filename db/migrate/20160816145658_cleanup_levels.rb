class CleanupLevels < ActiveRecord::Migration
  def change
    change_column :level_badges, :level_id, :integer, null: false
    change_column :level_badges, :badge_id, :integer, null: false
    change_column :level_badges, :created_at, :datetime, null: false
    change_column :level_badges, :updated_at, :datetime, null: false
    
    change_column :levels, :name, :string, null: false
    change_column :levels, :criterion_id, :integer, null: false
    change_column :levels, :created_at, :datetime, null: false
    change_column :levels, :updated_at, :datetime, null: false
  end
end
