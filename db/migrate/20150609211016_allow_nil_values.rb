class AllowNilValues < ActiveRecord::Migration
  def change
    change_column_default(:grades, :raw_score, nil)
    change_column_default(:grades, :predicted_score, nil)
  end
end
