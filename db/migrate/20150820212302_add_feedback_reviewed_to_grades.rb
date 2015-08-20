class AddFeedbackReviewedToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :feedback_reviewed, :boolean, default: false
  end
end
