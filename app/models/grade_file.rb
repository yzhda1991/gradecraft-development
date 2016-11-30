class GradeFile < ActiveRecord::Base
  belongs_to :grade
  belongs_to :file
end
