FactoryBot.define do
  factory :badge do
    association :course
    name { Faker::Internet.domain_word }
    full_points { rand(200) + 100 }
    icon { "badge.png" }
    can_earn_multiple_times { true }
    visible { true }
    visible_when_locked { true }
    show_name_when_locked { true }
    show_points_when_locked { true }
    show_description_when_locked { true }
  end
end
