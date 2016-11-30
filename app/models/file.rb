# This class currently handles grade files, it can be expanded to handle
# submission files and badge files to reduce the number of models needed
# to handle associated files.

class File < ActiveRecord::Base
  include S3Manager::Carrierwave

  belongs_to :grade, inverse_of: :files

  validates :filename, presence: true, length: { maximum: 50 }

  mount_uploader :file, AttachmentUploader
  process_in_background :file

  def course
    grade.course
  end

  def assignment
    grade.assignment
  end
end
