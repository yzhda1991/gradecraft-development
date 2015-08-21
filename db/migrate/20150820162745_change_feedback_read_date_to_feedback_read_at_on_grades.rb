class ChangeFeedbackReadDateToFeedbackReadAtOnGrades < ActiveRecord::Migration
  def change
    rename_column :grades, :feedback_read_date, :feedback_read_at
  end
end
