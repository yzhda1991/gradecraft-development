class UnlockCondition < ActiveRecord::Base

  attr_accessible :unlockable_id, :unlockable_type, :condition_id, :condition_type,
  :condition_state, :condition_value, :condition_date

  belongs_to :unlockable, :polymorphic => true
  belongs_to :condition, :polymorphic => true

  validates_presence_of :condition_id, :condition_type, :condition_state
  validates_associated :unlockable

  # Returning the name of whatever badge or assignment has been identified as the condition
  def name
    condition.name
  end

  def unlockable_name
    unlockable.name
  end

  def is_complete?(student)
    if condition_type == "Badge"
      check_badge_condition(student)
    elsif condition_type == "Assignment"
      check_assignment_condition(student)
    end
  end

  private 

  def check_badge_condition(student)
    badge = student.earned_badge_for_badge(condition_id)
    if badge.present? 
      if condition_value? && condition_date?
        check_if_badge_earned_enough_times_by_date(student)
      elsif condition_value?
        check_if_badge_earned_enough_times(student)
      else
        return true
      end
    else
      return false
    end
  end

  def check_if_badge_earned_enough_times(student)
    badge_count = student.earned_badges_for_badge_count(condition_id)
    if badge_count >= condition_value
      return true
    else
      return false
    end
  end

  def check_if_badge_earned_enough_times_by_date(student)
    badge_count = student.earned_badges_for_badge_count(condition_id)
    if badge_count >= condition_value &&
      (student.earned_badges.where(:badge_id => condition_id).last.created_at < condition_date)
        return true
    else
      return false
    end
  end

  def check_assignment_condition(student)
    if condition_state == "Submitted"
      check_submission_condition(student)
    elsif condition_state == "Grade Earned"
      check_grade_earned_condition(student)
    elsif condition_state == "Feedback Read"
      check_feedback_read_condition(student)
    end
  end

  def check_submission_condition(student)
    assignment = Assignment.find(condition_id)
    submission = student.submission_for_assignment(assignment)
    if submission.present?
      if condition_date?
        check_if_submitted_by_condition_date(submission)
      else 
        return true
      end
    else
      return false
    end
  end

  def check_if_submitted_by_condition_date(submission)
    if submission.updated_at < condition_date
      return true
    else
      return false
    end
  end

  def check_grade_earned_condition(student)
    grade = student.grade_for_assignment_id(condition_id).first
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
    elsif grade.is_student_visible?
      return true
    else
      return false
    end
  end

  def check_if_grade_earned_meets_condition_value(grade)
    if grade.is_student_visible? && grade.score >= condition_value
      return true
    else 
      return false
    end
  end

  def check_if_grade_earned_met_condition_date(grade)
    if grade.is_student_visible? && grade.updated_at < condition_date
      return true
    else 
      return false
    end
  end

  def check_feedback_read_condition(student)
    grade = student.grade_for_assignment_id(condition_id).first
    if grade.feedback_read?
      if condition_date?
        if (grade.feedback_read_at < condition_date)
          return true
        else 
          return false
        end
      else 
        return true
      end
    else
      return false
    end
  end

end