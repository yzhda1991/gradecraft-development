class RemoveSubmissionFromEarnedBadges < ActiveRecord::Migration
  def change
    remove_column :earned_badges, :submission_id
    remove_column :earned_badges, :assignment_id
    remove_column :earned_badges, :points
  end
end
