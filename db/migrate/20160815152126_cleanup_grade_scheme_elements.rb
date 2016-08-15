class CleanupGradeSchemeElements < ActiveRecord::Migration
  def change
    remove_column :grade_scheme_elements, :grade_scheme_id
    change_column :grade_scheme_elements, :description, :text
  end
end
