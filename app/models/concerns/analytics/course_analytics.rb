# Analytic responses to do with Course Scores
module Analytics
  module CourseAnalytics
    extend ActiveSupport::Concern

    def student_count
      course_memberships.where(role: "student", active: true).count
    end

    def graded_student_count
      course_memberships.being_graded.count
    end

    def groups_to_review_count
      groups.pending.count
    end

    def scores
      course_memberships.being_graded.pluck(:score).sort
    end

    def average_score
      course_memberships.being_graded.average(:score)
    end

    def high_score
      course_memberships.being_graded.maximum(:score)
    end

    def low_score
      scorable_memberships.minimum(:score)
    end

    def submitted_assignment_types_this_week
      assignment_types_this_week = assignment_types.with_submissions_this_week
      assignment_types_this_week.reject { |type| type.submissions.all?(&:unsubmitted?) }
    end

    private

    def scorable_memberships
      @scorable_memberships ||= course_memberships.where(role: "student", auditing: false, active: true)
    end
  end
end
