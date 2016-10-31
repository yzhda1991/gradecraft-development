class ChangePositionsToDefault < ActiveRecord::Migration[5.0]
  def change
    change_column :assignments, :position, :integer, null: false
    change_column :badges, :position, :integer, null: false
  end
end
