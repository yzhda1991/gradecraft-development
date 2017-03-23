# Analytic responses to do with Scores

module Analysable
  extend ActiveSupport::Concern

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
      if pass_fail?
        return student_grade.pass_fail_status
      else
        # should this be unweighted full points? (inc. adjustment points)
        return student_grade.raw_points
      end
    end
    nil
  end

  def graded_or_released_scores
    if pass_fail?
      # no use case currently
      grades.graded_or_released.pluck(:pass_fail_status)
    else
      grades.graded_or_released.pluck(:final_points)
    end
  end

  def grade_count
    return 0 if graded_or_released_scores.nil?
    return graded_or_released_scores.count if self.is_individual?
    return grades.select(:group_id).distinct.count if self.has_groups?
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

