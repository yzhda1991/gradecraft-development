class AssignmentTypeWeightStruct < Struct.new(:student, :assignment_type)
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :weight

  def weight
    @weight ||= assignment_type.weights.where(student: student).first.try(:weight) || 0
  end

  def assignment_type_id
    assignment_type.id
  end

  def save
    if valid?
      save_assignment_type_weights
      true
    else
      false
    end
  end

  def persisted?
    false
  end

  private

  def save_assignment_type_weights
    assignment_weight = assignment_type.weights.where(student: student).first_or_initialize
    assignment_weight.weight = weight
    assignment_weight.save!
    student.grades.where(assignment_type: assignment_type).each {|grade| grade.save!}
  end
end
