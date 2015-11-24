class SubmissionFile < ActiveRecord::Base
  include S3File

  attr_accessible :file, :filename, :filepath, :submission_id

  belongs_to :submission

  mount_uploader :file, AttachmentUploader
  process_in_background :file

  has_paper_trail

  validates :filename, presence: true, length: { maximum: 50 }
  validates :file, file_size: { maximum: 40.megabytes.to_i }

  def course
    submission.course
  end

  def assignment
    submission.assignment
  end

  def owner_name
    if submission.assignment.grade_scope == "Group"
      submission.group.name
    else
      "#{submission.student.last_name} #{submission.student.first_name}"
    end
  end

  def extension
    File.extname(filename)
  end

  def content_type
    file.content_type
    # type = file.url.match(/\.(\S+)$/)[1]
    # case type
    # when 'jpg','png','gif'

    # end
  end
end
