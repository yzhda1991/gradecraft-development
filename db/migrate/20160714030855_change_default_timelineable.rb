class ChangeDefaultTimelineable < ActiveRecord::Migration
  def change
    change_column :assignments, :include_in_timeline, :boolean, default: false, null: false
  end
end
