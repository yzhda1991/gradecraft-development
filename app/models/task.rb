class Task < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :course
  has_many :submissions, dependent: :destroy

  before_validation :set_course

  private

  def set_course
    self.course_id = assignment.try(:course_id)
  end
end
