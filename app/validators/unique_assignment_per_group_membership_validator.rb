class UniqueAssignmentPerGroupMembershipValidator < ActiveModel::EachValidator
  # We need to make sure students only belong to one group working on a
  # single assignment
  def validate(record)
    record.assignments.each do |a|
      record.students.each do |s|
        if s.group_for_assignment(a).present? && s.group_for_assignment(a).id != record.id
          record.errors.add :base, "#{s.name} is already working on this with another #{(record.course.group_term)}."
        end
      end
    end
  end
end
