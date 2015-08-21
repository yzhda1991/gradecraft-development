class AddFeedbackReviewedAtToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :feedback_reviewed_at, :datetime
  end
end
