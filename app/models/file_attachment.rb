# This class currently handles grade files, it should be expanded to handle
# submission files and badge files to reduce the number of models needed
# to handle associated files. It is named FileAttachment since "File" is
# already a ruby class.

class FileAttachment < ActiveRecord::Base
  include S3Manager::Carrierwave

  belongs_to :grade, inverse_of: :file_attachments

  validates :filename, presence: true, length: { maximum: 50 }

  mount_uploader :file, AttachmentUploader
  process_in_background :file

  def course
    grade.course
  end

  def assignment
    grade.assignment
  end

  def klass_name
    "grade_files"
  end
end
