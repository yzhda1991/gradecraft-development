# Earned Level Badges are EarnedBadges that are earned on a specific level of a
# a rubric criteria. They are treated uniquely here to allow for
# future services that build EarnedBadges for other associations
# (submission, assignment, etc.)

module Services
  module Actions
    class BuildsEarnedLevelBadges
      extend LightService::Action

      expects :student
      expects :assignment
      expects :criterion_grades
      expects :grade

      promises :earned_level_badges

      executed do |context|
        context[:earned_level_badges] = []
        level_ids = context[:criterion_grades].map { |cg| cg.level_id }
        level_ids.each do |id|
          level = Level.find(id)
          level.level_badges.each do |level_badge|
            context[:earned_level_badges] << EarnedBadge.find_or_create_by(
              student_id: context[:student].id,
              badge_id: level_badge.badge.id,
              level_id: level.id
            ).update(
              assignment_id: context[:assignment].id,
              course_id: context[:assignment].course.id,
              points: level_badge.badge.full_points,
              grade_id: context[:grade].id
            )
          end
        end
      end
    end
  end
end
