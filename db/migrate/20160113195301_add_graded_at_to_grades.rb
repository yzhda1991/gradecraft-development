class AddGradedAtToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :graded_at, :datetime
  end
end
