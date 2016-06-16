class AllowNilGradeValues < ActiveRecord::Migration
  def change
    change_column_null(:grades, :raw_points, true)
    change_column_null(:grades, :predicted_score, true)
  end
end
