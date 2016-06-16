class AllowNilValues < ActiveRecord::Migration
  def change
    change_column_default(:grades, :raw_points, nil)
    change_column_default(:grades, :predicted_score, nil)
  end
end
