module Gradable
  extend ActiveSupport::Concern

  included do
    has_many :grades, dependent: :destroy
    has_many :predicted_earned_grades, dependent: :destroy

    accepts_nested_attributes_for :grades, reject_if: :no_grade
  end

  def no_grade(attrs)
    pass_fail ? attrs[:pass_fail_status].blank? : attrs[:raw_points].blank?
  end

  def graded_or_released_scores
    grades.graded_or_released.pluck(:raw_points)
  end

  def grade_count
    grades.graded_or_released.count
  end

  # Getting a student's grade object for an assignment
  def grade_for_student(student)
    grades.graded_or_released.where(student_id: student.id).first
  end

  def average
    grades.graded_or_released.average(:raw_points).to_i \
      if grades.graded_or_released.present?
  end

  # Average of above-zero grades for an assignment
  def earned_average
    grades.graded_or_released.where("score > 0").average(:score).to_i
  end

  # Calculating how many of each score exists
  def earned_score_count
    grades.graded_or_released
      .group_by { |g| g.raw_points }
      .map { |score, grade| [score, grade.size ] }.to_h
  end

  def high_score
    grades.graded_or_released.maximum(:raw_points)
  end

  def low_score
    grades.graded_or_released.minimum(:raw_points)
  end

  def is_predicted_by_student?(student)
    grade = predicted_earned_grades.where(student_id: student.id).first
    !grade.nil? && grade.predicted_points > 0
  end

  def median
    sorted = grades.graded_or_released.not_nil.pluck(:score).sort
    return 0 if sorted.empty?
    (sorted[(sorted.length - 1) / 2] + sorted[sorted.length / 2]) / 2
  end

  def predicted_count
    predicted_earned_grades.predicted_to_be_done.count
  end

  def ungraded_students(ids_to_include=[], team=nil)
    if team
      students = course.students_by_team(team).order_by_name
    else
      students = course.students.order_by_name
    end
    students - (User.find(grades.graded_or_released.pluck(:student_id)) - User.find(ids_to_include))
  end

  def ungraded_students_with_submissions(ids_to_include=[], team=nil)
    ungraded_students(ids_to_include, team) & User.find(submissions.pluck(:student_id))
  end

  def next_ungraded_student(student, team=nil)
    if accepts_submissions?
      ungraded = ungraded_students_with_submissions([student.id], team)
    else
      ungraded = ungraded_students([student.id], team)
    end
    i = ungraded.map(&:id).index(student.id)
    i && i < ungraded.length - 1 ? ungraded[i + 1] : nil
  end

  def ungraded_groups
    ungraded_students.map { |student| student.group_for_assignment(self) }.uniq
  end

  def next_ungraded_group(group)
    if has_groups?
      if accepts_submissions?
        # groups with submissions, no grades
      else
        # groups with no grades
      end
    end
  end
end
