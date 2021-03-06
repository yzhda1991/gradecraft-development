# Earned Level Badges are EarnedBadges that are earned on a specific level of a
# a rubric criteria. They are treated uniquely here to allow for
# other services that build EarnedBadges for other associations
# (earned on a Grade, or awarded on the course level, for instance).

module Services
  module Actions
    class BuildsEarnedLevelBadges
      extend LightService::Action

      expects :student
      expects :criterion_grades
      expects :grade
      expects :graded_by_id

      promises :earned_level_badges

      executed do |context|
        context[:earned_level_badges] = []
        level_ids = (context[:criterion_grades].map { |cg| cg.level_id }).compact
        level_ids.each do |id|
          level = Level.find(id)
          level.level_badges.each do |level_badge|
            elb = EarnedBadge.find_or_create_by(
              student_id: context[:student].id,
              badge_id: level_badge.badge.id,
              level_id: level.id
            )
            elb.update(
              grade_id: context[:grade].id,
              awarded_by_id: context[:graded_by_id]
            )
            context[:earned_level_badges] << elb
          end
        end
      end
    end
  end
end
