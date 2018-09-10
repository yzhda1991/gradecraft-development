class UnlockCondition < ApplicationRecord
  include Copyable

  belongs_to :course
  belongs_to :unlockable, polymorphic: true
  belongs_to :condition, polymorphic: true

  validates_presence_of :condition_id, :condition_type, :condition_state
  validates_associated :unlockable
  validates_presence_of :course

  # Returning the name of whatever badge or assignment has been identified as
  # the condition
  def name
    return "Points earned" unless condition.present?
    condition.name
  end

  def unlockable_name
    unlockable.name
  end

  def is_complete?(student)
    method = "check_#{condition_type.underscore}_condition"
    self.send method, student
  end

  def is_complete_for_group?(group)
    check_condition_for_each_student(group)
  end

  # Human readable sentence to describe what students need to do to unlock this
  def requirements_description_sentence(condition_date_timezone=nil)
    if condition_type == "Course"
      description = "#{ condition_state_do } #{ condition_value } points in this course"
    elsif condition_type == "AssignmentType"
      if condition_state == "Minimum Points Earned"
        description = "#{ condition_state_do } #{ condition_value } points in the #{ condition.name } #{unlockable.course.assignment_term} Type"
      elsif condition_state == "Assignments Completed"
        description = "#{ condition_state_do } in the #{ condition.name } #{unlockable.course.assignment_term} Type"
      end
    else
      description = "#{ condition_state_do } the #{ condition.name } #{ condition_type }"
    end
    description += " by #{ formatted_condition_date(condition_date_timezone) }" if condition_date.present?
    description
  end

  def requirements_completed_sentence
    return "#{ condition_state_past } the #{ condition.name } #{ condition_type }" unless condition_type == "Course"
    return "Earned #{ condition_value } points in this course"
  end

  # Human readable sentence to describe what doing work on this thing unlocks
  def key_description_sentence
    "#{ condition_state_doing } unlocks the #{ unlockable.name } #{ unlockable_type }"
  end

  # Counting how many students in a group have done the work to unlock an
  # assignment
  def count_unlocked_in_group(group)
    unlocked_count = 0
    return 0 unless group.present?
    group.students.each do |student|
      unlocked_count += 1 if self.is_complete?(student)
    end
    return unlocked_count
  end

  def copy(attributes={}, lookup_store=nil)
    ModelCopier.new(self, lookup_store).copy(
      attributes: attributes,
      options: { lookups: [:courses, :unlockables, :conditions] }
    )
  end

  protected

  def condition_value
    self[:condition_value] || 0
  end

  private

  def condition_state_do
    if condition_state == "Submitted"
      "Submit"
    elsif condition_state == "Grade Earned"
      "Earn a grade for"
    elsif condition_state == "Feedback Read"
      "Read the feedback for"
    elsif condition_state == "Earned" || condition_state == "Minimum Points Earned"
      "Earn"
    elsif condition_state == "Passed"
      "Pass"
    elsif condition_state == "Minimum Points Earned"
      "Earn"
    elsif condition_state == "Assignments Completed"
      "Complete #{condition_value} #{unlockable.course.assignment_term.pluralize.downcase}"
    end
  end

  def condition_state_doing
    if condition_state == "Submitted"
      "Submitting it"
    elsif condition_state == "Grade Earned"
      "Earning a grade for it"
    elsif condition_state == "Feedback Read"
      "Reading the feedback for it"
    elsif condition_state == "Earned"
      "Earning it"
    elsif condition_state == "Passed"
      "Passing it"
    elsif condition_state == "Minimum Points Earned"
      "Earning #{condition_value} points"
    elsif condition_state == "Assignments Completed"
      "Completing #{condition_value} #{unlockable.course.assignment_term.pluralize.downcase}"
    end
  end

  def condition_state_past
    if condition_state == "Submitted"
      "Submitted"
    elsif condition_state == "Grade Earned"
      "Earned a grade for"
    elsif condition_state == "Feedback Read"
      "Read the feedback for"
    elsif condition_state == "Earned"
      "Earned"
    elsif condition_state == "Passed"
      "Passed"
    elsif condition_state == "Minimum Points Earned"
      "Earned #{condition_value} points in"
    elsif condition_state == "Assignments Completed"
      "Completed #{condition_value} #{unlockable.course.assignment_term.pluralize.downcase} in"
    end
  end

  def formatted_condition_date(timezone)
    timezone.nil? ? condition_date : condition_date.in_time_zone(timezone)
  end

  def check_assignment_type_condition(student)
    method = "check_#{ condition_state.parameterize(separator: '_') }_condition"
    self.send method, student
  end

  def check_assignments_completed_condition(student)
    assignment_type = AssignmentType.find(condition_id)
    assignment_completed_count = assignment_type.count_grades_for(student)
    assignment_completed_count >= condition_value
  end

  def check_minimum_points_earned_condition(student)
    assignment_type = AssignmentType.find(condition_id)
    assignment_type_score = assignment_type.score_for_student(student)
    assignment_type_score >= condition_value
  end

  def check_badge_condition(student)
    badge = student.awarded_badges_for_badge(condition)
    return false unless badge.present?
    if condition_value? && condition_date?
      check_if_badge_earned_enough_times_by_date(student)
    elsif condition_value?
      check_if_badge_earned_enough_times(student)
    else
      return true
    end
  end

  def check_if_badge_earned_enough_times(student)
    badge_count = student.awarded_badges_for_badge_count(condition_id)
    badge_count >= condition_value
  end

  def check_if_badge_earned_enough_times_by_date(student)
    badge_count = student.awarded_badges_for_badge_count(condition_id)
    badge_count >= condition_value && student.earned_badges.where(badge_id: condition_id).last.created_at < condition_date
  end

  def check_assignment_condition(student)
    method = "check_#{ condition_state.parameterize(separator: "_") }_condition"
    self.send method, student
  end

  def check_submitted_condition(student)
    assignment = Assignment.find(condition_id)
    if student.has_group_for_assignment? assignment
      group = student.group_for_assignment(assignment)
      submission = group.submission_for_assignment(assignment)
    elsif assignment.is_individual?
      submission = student.submission_for_assignment(assignment)
    end
    return false unless submission.present?
    return true unless condition_date?
    check_if_submitted_by_condition_date(submission)
  end

  def check_if_submitted_by_condition_date(submission)
    submission.submitted_at < condition_date
  end

  def check_grade_earned_condition(student)
    grade = student.grade_for_assignment_id(condition_id).first
    return false unless grade && grade.final_points.present? && grade.final_points > 0
    if condition_value? && condition_date?
      if check_if_grade_earned_meets_condition_value(grade) &&
      check_if_grade_earned_met_condition_date(grade)
        return true
      else
        return false
      end
    elsif condition_value?
      check_if_grade_earned_meets_condition_value(grade)
    elsif condition_date?
      check_if_grade_earned_met_condition_date(grade)
    elsif GradeProctor.new(grade).viewable?(user: student)
      return true
    else
      return false
    end
  end

  def check_passed_condition(student)
    grade = student.grade_for_assignment_id(condition_id).first
    return false unless grade.present?
    grade.pass_fail_status == "Pass"
  end

  def check_if_grade_earned_meets_condition_value(grade)
    GradeProctor.new(grade).viewable? && grade.score >= condition_value
  end

  def check_if_grade_earned_met_condition_date(grade)
    GradeProctor.new(grade).viewable? &&
      grade.graded_at < condition_date
  end

  def check_feedback_read_condition(student)
    grade = student.grade_for_assignment_id(condition_id).first
    return false unless grade.present? && grade.feedback_read?
    return true unless condition_date?
    grade.feedback_read_at < condition_date
  end

  def check_course_condition(student)
    course_membership = student.course_memberships.where(course_id: condition_id).first
    course_membership.score >= condition_value if course_membership.present?
  end

  # Checking if the number of students who have completed the condition match
  # the size of the group, returning true if so.
  def check_condition_for_each_student(group)
    unlocked_count = count_unlocked_in_group(group)
    unlocked_count == group.students.count
  end
end
