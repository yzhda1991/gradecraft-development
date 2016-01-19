# Earned Level Badges are EarnedBadges that are earned on a specific level of a
# a rubric criteria. They are treated uniquely here to allow for
# future services that build EarnedBadges for other associations
# (submission, assignment, etc.)

module Services
  module Actions
    class BuildsEarnedLevelBadges
      extend LightService::Action

      expects :raw_params
      expects :student
      expects :assignment
      expects :student_visible_status

      promises :earned_level_badges

      executed do |context|

        # Returns an empty array if no level_badges in raw_params
        # expects: "level_badges" => [{ "badge_id"=>1, "level_id"=>1 },..]
        context[:earned_level_badges] = context[:raw_params]["level_badges"].nil? ?
          [] :
          new_earned_level_badges(
            context[:assignment],
            context[:student],
            !!context[:student_visibile_status], # lightservice sends false as nil
            context[:raw_params]["level_badges"]
          )
      end

      private

      def self.new_earned_level_badges(assignment, student, visible_status, level_badges_params)
        level_badges_params.collect do |params|

          level_badge = LevelBadge.where(badge_id: params["badge_id"], level_id: params["level_id"]).first

          EarnedBadge.new({
            course_id: assignment.course.id,
            assignment_id: assignment.id,
            student_id: student.id,
            student_visible: visible_status,
            badge_id: level_badge.badge.id,
            level_id: level_badge.level.id,
            score: level_badge.badge.point_total,
          })
        end
      end
    end
  end
end
