class SubmissionDate < ActiveRecord::Migration
  def change
    add_column :submissions, :submitted_at_date, :datetime
    add_column :submissions, :resubmission, :boolean, default: false
  end
end
