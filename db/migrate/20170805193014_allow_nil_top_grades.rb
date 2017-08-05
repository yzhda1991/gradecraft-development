class AllowNilTopGrades < ActiveRecord::Migration[5.0]
  def change
    change_column :assignment_types, :top_grades_counted, :integer, default: nil, null: true
  end
end
