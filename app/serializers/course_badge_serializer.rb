class CourseBadgeSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :point_total, :icon, :multiple
  has_many :student_earned_badges, serializer: EarnedBadgeSerializer

  def student_earned_badges
    if @student_id
      earned_badges.where(student_id: @options[:student_id])
    else
      []
    end
  end

  def multiple
    object.can_earn_multiple_times
  end

  def icon
    object.icon.url
  end
end
