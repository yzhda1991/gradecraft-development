class AssignmentGroupPresentValidator < ActiveModel::EachValidator
# Checking to make sure the group is actually working on an assignment
  def validate(record)
    if record.assignment_groups.to_a.size == 0
      record.errors[attribute] << "You need to check off which #{(course.assignment_term).downcase} your #{(course.group_term).downcase} will work on."
    end
  end
end
