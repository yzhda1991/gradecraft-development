# Analytics concerning badges and earned badges
module Analytics
  module BadgeAnalytics
    extend ActiveSupport::Concern

    # indexed badges
    def earned_count
      earned_badges.student_visible.count
    end

    def earned_badge_total_points_for_student(student)
      earned_badge_count_for_student(student) * self.full_points
    end

    def earned_badges_this_week_count
      earned_badges.submitted_by_active_students.where("earned_badges.updated_at > ? ", 7.days.ago).count
    end
  end
end
