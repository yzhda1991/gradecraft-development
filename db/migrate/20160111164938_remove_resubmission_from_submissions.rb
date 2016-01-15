class RemoveResubmissionFromSubmissions < ActiveRecord::Migration
  def change
    remove_column :submissions, :resubmission
  end
end
