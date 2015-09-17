class DropDuplicates < ActiveRecord::Migration
  def change
    drop_table :duplicated_users
    drop_table :submission_files_duplicate
  end
end
