class AddTextCommentDraftToSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :text_comment_draft, :text
  end
end
