FactoryBot.define do
  factory :grade_scheme_element do
    association :course
    lowest_points 0

    factory :grade_scheme_element_high do
      lowest_points 10000
      letter { "A" }
      level { "Amazing" }
    end

    factory :grade_scheme_element_low do
      lowest_points 0
      letter { "F" }
      level { "Awful" }
    end

    factory :grade_scheme_element_highest do
      lowest_points 20001
      letter { "A+" }
      level { "Ahhhmazing" }
    end
  end
end
