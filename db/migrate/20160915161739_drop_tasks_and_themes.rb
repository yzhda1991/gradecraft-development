class DropTasksAndThemes < ActiveRecord::Migration
  def change
    drop_table :tasks
    drop_table :themes
  end
end
