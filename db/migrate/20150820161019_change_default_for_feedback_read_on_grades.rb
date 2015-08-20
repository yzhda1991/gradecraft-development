class ChangeDefaultForFeedbackReadOnGrades < ActiveRecord::Migration
  def change
    change_column :grades, :feedback_read, :boolean, default: false
  end
end
