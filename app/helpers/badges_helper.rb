module BadgesHelper
  def sidebar_earned_badge(badge, student)
    content_tag(:a) do
      concat image_tag(badge.icon, alt: "You have earned the #{badge.name} badge", class: "earned")
    end.concat(
      content_tag(:div, nil, class: "display-on-hover hover-style right") do
        hover_content = "#{badge.name}#{", #{points badge.full_points} points" if badge.full_points.present? && badge.full_points > 0}"
        if badge.is_unlockable?
          lock_icon_class = badge.is_unlocked_for_student?(student) ? "fa-unlock-alt" : "fa-lock"
          concat content_tag(:i, hover_content, class: "fa #{lock_icon_class}")
        else
          concat hover_content
        end
      end
    )
  end
end
