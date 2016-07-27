class AddGroupSizetoAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :min_group_size, :integer, default: 1, null: false
    add_column :assignments, :max_group_size, :integer, default: 5, null: false
  end
end
