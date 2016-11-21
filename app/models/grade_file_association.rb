class GradeFileAssociation < ActiveRecord::Base
  belongs_to :grade
  belongs_to :grade_file
end
