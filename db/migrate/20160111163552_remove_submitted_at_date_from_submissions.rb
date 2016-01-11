class RemoveSubmittedAtDateFromSubmissions < ActiveRecord::Migration
  def change
    remove_column :submissions, :submitted_at_date
  end
end
