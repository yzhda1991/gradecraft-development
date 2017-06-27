# Analytic responses to do with Scores for Assigment
module Analytics
  module AssignmentAnalytics
    extend ActiveSupport::Concern

    def average
      grades.graded_or_released.for_active_students.average(:raw_points).to_i \
        if grades.graded_or_released.present?
    end

    # Average of above-zero grades for an assignment
    def earned_average
      grades.for_active_students.graded_or_released.where("grades.score > 0").average(:score).to_i
    end

    def high_score
      grades.graded_or_released.for_active_students.maximum(:raw_points)
    end

    def low_score
      grades.graded_or_released.for_active_students.minimum(:raw_points)
    end

    def median
      sorted = grades.graded_or_released.for_active_students.not_nil.pluck(:score).sort
      return 0 if sorted.empty?
      (sorted[(sorted.length - 1) / 2] + sorted[sorted.length / 2]) / 2
    end

    # Calculating how many of each pass/fail exists
    def earned_status_count
      grades.graded_or_released
        .group_by { |g| g.pass_fail_status }
        .map { |score, grade| [score, grade.size ] }.to_h
    end

    # Calculating how many of each score exists
    # {1236=>1, 4935=>5, 3293=>10, 3566=>15, 2255=>10...}
    def earned_score_count
      grades.graded_or_released
        .group_by { |g| g.raw_points }
        .map { |score, grade| [score, grade.size ] }.to_h
    end

    # pass-fail:
    # standard: [{:frequency=>1, :score=>1236}, {:frequency=>5, :score=>4935},...]
    def score_frequency
      if pass_fail?
        earned_status_count.collect { |s| { frequency: s[1], score: s[0] }}
      else
        earned_score_count.collect { |s| { frequency: s[1], score: s[0] }}
      end
    end

    def score_for(student_id, viewer)
      student_grade = grades.where(student_id: student_id).first
      if GradeProctor.new(student_grade).viewable? user: viewer, course: course
        return student_grade.pass_fail_status if pass_fail?
        # should this be unweighted full points? (inc. adjustment points)
        return student_grade.raw_points
      end
      nil
    end

    def graded_or_released_scores
      if pass_fail?
        # no use case currently
        grades.graded_or_released.for_active_students.pluck(:pass_fail_status)
      else
        grades.graded_or_released.for_active_students.pluck(:final_points)
      end
    end

    def grade_count
      return 0 if graded_or_released_scores.nil?
      return graded_or_released_scores.count if self.is_individual?
      return grades.select(:group_id).distinct.count if self.has_groups?
    end

    def predicted_count
      predicted_earned_grades.predicted_to_be_done.count
    end

    # Tallying the percentage of participation from the entire class
    def participation_rate
      return 0 if participation_possible_count == 0
      ((grade_count.to_f / participation_possible_count.to_f) * 100).round(2)
    end

    # denominator
    def participation_possible_count
      return course.graded_student_count if is_individual?
      return groups.count if has_groups?
      0
    end
  end
end
