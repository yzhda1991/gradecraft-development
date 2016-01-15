class RemoveTextFeedbackFromSubmissions < ActiveRecord::Migration
  def change
    remove_column :submissions, :text_feedback
  end
end
