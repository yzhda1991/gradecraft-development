class DropGradeSchemes < ActiveRecord::Migration
  def change
    drop_table :grade_schemes
  end
end
