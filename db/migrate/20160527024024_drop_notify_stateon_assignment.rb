class DropNotifyStateonAssignment < ActiveRecord::Migration
  def change
    remove_column :assignments, :notify_released
  end
end
