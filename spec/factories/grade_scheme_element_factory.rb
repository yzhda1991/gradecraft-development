FactoryGirl.define do
  factory :grade_scheme_element do
    association :course
    lowest_points 0
    highest_points 100000

    factory :grade_scheme_element_high do
      lowest_points 10000
      highest_points 20000
      letter { "A" }
      level { "Amazing" }
    end

    factory :grade_scheme_element_low do
      lowest_points 0
      highest_points 9999
      letter { "F" }
      level { "Awful" }
    end

  end
end
