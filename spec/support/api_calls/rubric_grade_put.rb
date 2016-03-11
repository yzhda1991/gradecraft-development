# Example API call from the GradeRubricCtrl.js

# Note this is to document the current state of this call,
# which should be optimized in the js and then updated here.

class RubricGradePUT
  attr_reader :world, :level_badge

  def initialize(old_world = nil)
    @world = old_world || World.create.with(:course, :student, :assignment, :rubric, :criterion, :criterion_grade, :badge)
    @level_badge = level_badge || LevelBadge.create(level_id: world.criterion.levels.first.id, badge_id: world.badge.id)
  end

  def assignment
    world.assignment
  end

  def student
    world.student
  end

  def rubric
    world.rubric
  end

  def criteria
    world.rubric.criteria
  end

  def criterion_grades_params
    criteria.collect { |c| criterion_grade_to_h(c) }
  end

  # "assignment id" and "student_id" or "group_id" is passed through the route
  def params
    { "points_possible" => assignment.point_total,
      "criterion_grades" => criterion_grades_params,
      "level_badges" => [level_badge_params(level_badge)],
      "level_ids" => (criteria.collect { |c| c.levels.pluck(:id) }).flatten,
      "criterion_ids" => criteria.pluck(:id),
      "controller" => "grades",
      "grade" => {
        "raw_score" => assignment.point_total - 10,
        "status" => "Released",
        "feedback" => "good jorb!",
        "adjustment_points" => "-10",
        "adjustment_points_feedback" => "reduced by 10 points"
      }
    }
  end

  private

  def criterion_grade_to_h(c)
    { "criterion_name" => c.name,
      "criterion_description" => "",
      "max_points" => c.max_points,
      "order" => c.levels.first.sort_order,
      "criterion_id" => c.id,
      "comments" => "sample comments for #{c.name}",
      "level_name" => c.levels.first.name,
      "level_description" => "",
      "points" => c.levels.first.points,
      "level_id" => c.levels.first.id
    }
  end

  def level_badge_params(lb)
    { "name" => "unused",
      "level_id" => lb.level.id,
      "criterion_id" => lb.level.criterion.id,
      "badge_id" => lb.badge.id,
      "description" => "unused",
      "point_total" => lb.badge.point_total,
      "icon" => "unused"
    }
  end
end
