namespace :attachments do

  desc "Add grade file association for many to many relationship"
  task add_associations: :environment do
    FileUpload.find_each(batch_size: 500) do |gf|
      if Attachment.where(file_upload_id: gf.id, grade_id: gf.grade_id).empty?
        Attachment.create(file_upload_id: gf.id, grade_id: gf.grade_id)
      end
    end
  end
end
