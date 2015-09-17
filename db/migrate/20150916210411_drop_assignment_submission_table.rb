class DropAssignmentSubmissionTable < ActiveRecord::Migration
  def change
    drop_table :assignment_submissions
  end
end
