module Analytics
  module UserAnalytics
    extend ActiveSupport::Concern

    def score_for_course(course)
      @score ||= course_memberships.where(course_id: course).first.score || 0 if
        course_memberships.where(course_id: course).first.present?
    end

    def grade_for_course(course)
      cm = course_memberships.where(course_id: course.id).first
      return cm.grade_scheme_element if cm.grade_scheme_element.present?
      return cm.earned_grade_scheme_element
    end

    def grade_level_for_course(course)
      @grade_level ||= grade_for_course(course).try(:level)
    end

    def grade_letter_for_course(course)
      @grade_letter_for_course ||= grade_for_course(course).try(:letter)
    end

    # Returning all of the grades a student has received this week
    def grades_released_for_course_this_week(course)
      grades = grades_for_course(course).where("graded_at > ? ", 7.days.ago)
      viewable_grades = []
      grades.each do |grade|
        viewable_grades << grade if GradeProctor.new(grade).viewable? && !grade.excluded_from_course_score
      end
      return viewable_grades
    end

    # Returning the total number of points for all grades released this week
    def points_earned_for_course_this_week(course)
      grades_released_for_course_this_week(course).map(&:final_points).compact.sum
    end

    def earned_badge_score_for_course(course)
      earned_badges.includes(:badge).where(course: course).student_visible.map(&:points).compact.sum
    end

    # returns all badges a student has earned for a particular course this week
    def earned_badges_for_course_this_week(course)
      earned_badges.student_visible.where(course: course).where("created_at > ? ", 7.days.ago)
    end
  end
end
