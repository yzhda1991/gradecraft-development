class CleanupUser < ActiveRecord::Migration
  def change
    remove_column :users, :rank
    remove_column :users, :private_display
    remove_column :users, :final_grade
    remove_column :users, :visit_count
    remove_column :users, :predictor_views
    remove_column :users, :page_views
  end
end
