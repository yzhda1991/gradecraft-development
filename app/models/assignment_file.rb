class AssignmentFile < ActiveRecord::Base
  include Copyable
  include S3Manager::Carrierwave

  belongs_to :assignment, inverse_of: :assignment_files

  validates :filename, presence: true, length: { maximum: 50 }

  mount_uploader :file, AttachmentUploader
  process_in_background :file

  def copy(attributes={})
    ModelCopier.new(self).copy(attributes: attributes,
                               options: { overrides: [-> (copy) {
                                          copy.file_processing = false
                                          copy.copy_s3_object_from(self.s3_object_file_key,
                                            "#{copy.file.store_dir}/#{self.mounted_filename}")
                                        }]})
  end

  def course
    assignment.course
  end
end
