class DropPointSetting < ActiveRecord::Migration
  def change
    remove_column :assignment_types, :point_setting
  end
end
