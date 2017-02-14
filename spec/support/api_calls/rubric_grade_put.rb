# API call from submitting a rubric grade: /angular/services/GradeService
class RubricGradePUT
  attr_reader :world, :level_badge

  def initialize(old_world = nil)
    @world = old_world || World.create.with(:course, :student, :assignment, :rubric, :criterion, :criterion_grade, :badge)
    @level_badge = level_badge || LevelBadge.create(level_id: world.criterion.levels.first.id, badge_id: world.badge.id)
  end

 # "assignment id" and "student_id" or "group_id" is passed through the route
  def assignment
    world.assignment
  end

  def criterion_grades_params
    world.rubric.criteria.collect { |c| criterion_grade_to_h(c) }
  end

  def params
    {
      "controller" => "grades",
      "criterion_grades" => criterion_grades_params,
      "grade" => {
        "raw_points" => assignment.full_points - 10,
        "status" => "Released",
        "feedback" => "good jorb!",
        "adjustment_points" => "-10",
        "adjustment_points_feedback" => "reduced by 10 points"
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
