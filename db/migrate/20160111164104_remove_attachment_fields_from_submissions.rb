class RemoveAttachmentFieldsFromSubmissions < ActiveRecord::Migration
  def change
    remove_column :submissions, :attachment_content_type
    remove_column :submissions, :attachment_file_name
    remove_column :submissions, :attachment_file_size
    remove_column :submissions, :attachment_updated_at
  end
end
