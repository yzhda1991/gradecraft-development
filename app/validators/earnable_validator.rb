class EarnableValidator < ActiveModel::EachValidator  
  def validate(record)
    record.errors.add :base, " Oops, they've already earned the '#{record.badge.name}' #{record.course.badge_term.downcase}." if !record.badge.available_for_student?(record.student)
  end
end
