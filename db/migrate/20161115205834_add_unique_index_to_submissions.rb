class AddUniqueIndexToSubmissions < ActiveRecord::Migration[5.0]
  def change
    remove_index :submissions, [:assignment_id, :student_id]
    add_index :submissions, [:assignment_id, :student_id], unique: true
  end
end
