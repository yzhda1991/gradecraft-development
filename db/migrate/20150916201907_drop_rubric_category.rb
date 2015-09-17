class DropRubricCategory < ActiveRecord::Migration
  def change
    drop_table :rubric_categories
  end
end
