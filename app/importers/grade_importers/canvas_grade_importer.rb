class CanvasGradeImporter
  attr_reader :successful, :unsuccessful
  attr_accessor :grades

  def initialize(grades)
    @grades = grades
    @successful = []
    @unsuccessful = []
  end

  def import(assignment_id, syllabus)
    unless grades.nil?
      grades.each do |canvas_grade|
        user = find_user canvas_grade["user_id"], syllabus
        grade = Grade.new assignment_id: assignment_id,
          student_id: user.try(:id),
          raw_points: canvas_grade["score"]
        grade.save
      end
    end

    self
  end

  private

  def find_user(user_id, syllabus)
    canvas_user = syllabus.user(user_id)
    if canvas_user
      User.find_by_insensitive_email(canvas_user["primary_email"])
    end
  end
end
