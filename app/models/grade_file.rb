class Attachment < ActiveRecord::Base
  belongs_to :grade
  belongs_to :file_upload
end
