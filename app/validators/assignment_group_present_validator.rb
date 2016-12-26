class AssignmentGroupPresentValidator < ActiveModel::EachValidator
  # Checking to make sure the group is actually working on an assignment
  def validate(record)
    record.errors.add :base, "You need to check off which #{(record.course.assignment_term).downcase} your #{(record.course.group_term).downcase} will work on." if record.assignment_groups.to_a.size == 0
  end
end
