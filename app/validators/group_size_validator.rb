class GroupSizeValidator < ActiveModel::EachValidator  
  # Checking to make sure any constraints the instructor has set up around
  # min/max group members are honored
  def validate(record)
    return false unless record.assignments.present?
    if record.students.to_a.size < record.assignments.first.min_group_size
      record.errors.add :base, "You don't have enough group members."
    elsif record.students.to_a.size > record.assignments.first.max_group_size
      record.errors.add :base, "You have too many group members."
    end
  end
end
