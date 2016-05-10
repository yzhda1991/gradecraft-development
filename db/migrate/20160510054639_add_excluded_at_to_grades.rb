class AddExcludedAtToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :excluded_at, :timestamp
  end
end
