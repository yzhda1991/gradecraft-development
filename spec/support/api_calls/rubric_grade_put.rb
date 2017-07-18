# API call from submitting a rubric grade: /angular/services/GradeService
# "assignment id" and "student_id" or "group_id" is passed through the route

class RubricGradePUT
  attr_reader :critera

  def initialize(assignment, criteria = nil)
    @assignment = assignment
    @criteria = criteria || []
  end

  def criterion_grades_params
    @criteria.collect { |c| criterion_grade_to_h(c) }
  end

  def params
    {
      "controller" => "grades",
      "criterion_grades" => criterion_grades_params,
      "grade" => {
        "adjustment_points" => "-10",
        "adjustment_points_feedback" => "reduced by 10 points",
        "feedback" => "good jorb!",
        "raw_points" => @assignment.full_points - 10,
        "complete" => true,
        "student_visible" => true
      }
    }
  end

  private

  def criterion_grade_to_h(c)
    { "criterion_id" => c.id,
      "level_id" => c.levels.first.id,
      "points" => c.levels.first.points,
      "comments" => "sample comments for #{c.name}",
    }
  end
end
