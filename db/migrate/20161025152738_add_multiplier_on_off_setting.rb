class AddMultiplierOnOffSetting < ActiveRecord::Migration
  def change
    add_column :courses, :has_multipliers, :boolean, default: false, null: false
  end
end
