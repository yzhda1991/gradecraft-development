# Analytic responses to do with Course Scores
module Analytics
  module CourseAnalytics
    extend ActiveSupport::Concern

    def scores
      scorable_memberships.pluck(:score).sort
    end

    def average_score
      scorable_memberships.average(:score)
    end

    def high_score
      scorable_memberships.maximum(:score)
    end

    def low_score
      scorable_memberships.minimum(:score)
    end

    private

    def scorable_memberships
      @scorable_memberships ||= course_memberships.where(role: "student", auditing: false)
    end
  end
end
