class BadgeSerializer
  Jbuilder.new do |badge|
    json.(badge, :id, :name, :description, :point_total, :icon, :multiple)

    if @student[:id]
      json.student_earned_badges earned_badges.where(student_id: @student[:id])
    end

    json.multiple badge.can_earn_multiple_times
    json.icon badge.icon.url
  end
end
