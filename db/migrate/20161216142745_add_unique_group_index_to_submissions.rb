class AddUniqueGroupIndexToSubmissions < ActiveRecord::Migration[5.0]
  def change
    remove_index :submissions, [:assignment_id, :group_id]
    add_index :submissions, [:assignment_id, :group_id], unique: true
  end
end
