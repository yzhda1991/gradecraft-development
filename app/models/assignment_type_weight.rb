class AssignmentTypeWeight < Struct.new(:student, :assignment_type)
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :weight

  def weight
    @weight ||= assignment_type.assignment_weights.where(student: student).first.try(:weight) || 0
  end

  def assignment_type_id
    assignment_type.id
  end

  def save
    if valid?
      save_assignment_weights
      true
    else
      false
    end
  end

  def persisted?
    false
  end

  private

  def save_assignment_weights
    assignment_type.assignments.each do |assignment|
      assignment_weight = assignment.weights.where(student: student).first_or_initialize
      assignment_weight.weight = weight
      assignment_weight.save!
      assignment.grades.where(student: student).each {|grade| grade.save!}
    end
  end
end
