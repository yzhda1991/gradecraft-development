FactoryGirl.define do
  factory :grade_scheme_element do
    association :course
    low_points 0
    high_points 100000

    factory :grade_scheme_element_high do
      low_points 10000
      high_points 20000
      letter { "A" }
      level { "Amazing" }
    end

    factory :grade_scheme_element_low do
      low_points 0
      high_points 9999
      letter { "F" }
      level { "Awful" }
    end

  end
end
