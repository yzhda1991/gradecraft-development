class GradeFile < ActiveRecord::Base
  include S3Manager::Carrierwave

  belongs_to :grade, inverse_of: :grade_files

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
