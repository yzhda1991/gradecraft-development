FactoryGirl.define do
  factory :badge do
    association :course
    name { Faker::Internet.domain_word }
    point_total { rand(200) + 100 }
    visible { true }
    icon { "badge.png" }
    can_earn_multiple_times true
  end
end
