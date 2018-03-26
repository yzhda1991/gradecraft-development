class AddBooleanResubmissionField < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :resubmission, :boolean, null: false, default: false
  end
end
