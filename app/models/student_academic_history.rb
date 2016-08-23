class StudentAcademicHistory < ActiveRecord::Base
  belongs_to :student, class_name: "User", foreign_key: :student_id
  belongs_to :course

  validates :gpa, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates_presence_of :course_id, :student_id
end
