class RemoveGradedFromSubmissions < ActiveRecord::Migration
  def change
    remove_column :submissions, :graded
  end
end
