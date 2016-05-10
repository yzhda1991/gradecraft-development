class AddExcludedByIdToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :excluded_by_id, :integer
  end
end
