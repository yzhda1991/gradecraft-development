# Called from the PredictedAssignmentCollectionSerializer, this class manages
# the presentation of an Assignment for the Predictor Page with the grade for
# a student nested within.

class PredictedAssignmentSerializer < SimpleDelegator
  attr_reader :current_user, :student

  def initialize(assignment, current_user, student)
    @assignment = assignment
    @current_user = current_user
    @student = student
    super assignment
  end

  def grade
    if @grade.nil?
      grade = student.present? ? Grade.find_or_create(assignment.id, student.id) : NullGrade.new
      @grade = PredictedGradeSerializer.new(grade, current_user)
    end
    @grade
  end

  def attributes
    select_attributes.merge boolean_flags
  end

  def predictor_display_type
    assignment.predictor_display_type
  end

  def score_levels
    assignment.assignment_score_levels.map do |asl|
      {name: asl.name, value: asl.value}
    end
  end

  def unlock_conditions
    assignment.unlock_conditions.map do |condition|
      "#{condition.name} must be #{condition.condition_state}"
    end
  end

  def unlock_keys
    assignment.unlock_keys.map do |key|
      "#{key.unlockable.name} is unlocked by #{key.condition_state} #{key.condition.name}"
    end
  end

  private
  attr_reader :assignment

  def select_attributes
    assignment.attributes.select do |attr,v|
      %w( accepts_submissions_until
          assignment_type_id
          description
          due_at
          id
          name
          pass_fail
          point_total
          position
        ).include?(attr)
    end
  end

  # boolean states for icons in predictor
  def boolean_flags
    {
      is_required: is_required?,
      has_info: has_info?,
      has_rubric: has_rubric?,
      accepts_submissions: accepts_submissions?,
      is_a_condition: is_a_condition?,
      is_earned_by_group: is_earned_by_group?,
      is_late: is_late?,
      has_closed: has_closed?,
      is_locked: is_locked?,
      has_been_unlocked: has_been_unlocked?,
    }
  end

  def is_required?
    !!assignment.required
  end

  def has_info?
    !assignment.description.blank?
  end

  def has_rubric?
    !!assignment.has_rubric?
  end

  def accepts_submissions?
    !!assignment.accepts_submissions?
  end

  def is_earned_by_group?
    assignment.grade_scope == "Group"
  end

  def is_late?
    assignment.overdue? && assignment.accepts_submissions && \
    !student.submission_for_assignment(assignment).present?
  end

  # TODO: update when closed? method added to assignments
  def has_closed?
    assignment.submissions_have_closed?
  end

  def is_locked?
    !assignment.is_unlocked_for_student?(student)
  end

  def has_been_unlocked?
    assignment.is_unlockable? && assignment.is_unlocked_for_student?(student)
  end

  def is_a_condition?
    assignment.is_a_condition?
  end
end
