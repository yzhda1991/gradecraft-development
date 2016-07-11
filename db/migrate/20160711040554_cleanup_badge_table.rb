class CleanupBadgeTable < ActiveRecord::Migration
  def change
    change_column :badges, :name, :string, null: false
    change_column :badges, :course_id, :integer, null: false
    remove_column :badges, :assignment_id
    change_column :badges, :created_at, :datetime, null: false
    change_column :badges, :updated_at, :datetime, null: false
    change_column :badges, :visible, :boolean, default: true, null: false
    change_column :badges, :can_earn_multiple_times, :boolean, default: true, null: false
    change_column :badges, :visible_when_locked, :boolean, default: true, null: false
    change_column :badges, :show_name_when_locked, :boolean, default: true, null: false
    change_column :badges, :show_description_when_locked, :boolean, default: true, null: false
  end
end
