class EarnedBadgeSerializer < ActiveModel::Serializer
  attributes :id, :student_id, :badge_id, :score, :student_visible, :grade_id, :assignment_id
end
