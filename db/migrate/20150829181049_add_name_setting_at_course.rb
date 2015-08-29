class AddNameSettingAtCourse < ActiveRecord::Migration
  def change
    add_column :courses, :character_names, :string
  end
end
