class ChangeRangeNomenclature < ActiveRecord::Migration
  def change
    rename_column :grade_scheme_elements, :low_points, :lowest_points
    rename_column :grade_scheme_elements, :high_points, :highest_points
  end
end
