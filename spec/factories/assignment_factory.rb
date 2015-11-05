FactoryGirl.define do
  factory :assignment do
    name { Faker::Lorem.word }
    association :assignment_type
    description { Faker::Lorem.sentence }
    point_total { Faker::Number.number(5) }
    visible true
    points_predictor_display 'Fixed'

    factory :individual_assignment do
      grade_scope 'Individual'
    end

    factory :group_assignment do 
    	grade_scope 'Group'
    end

    factory :individual_assignment_with_submissions do 
      grade_scope 'Individual'
      accepts_submissions true
    end
  end
end
