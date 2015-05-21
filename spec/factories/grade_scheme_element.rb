FactoryGirl.define do
  factory :grade_scheme_element do
    association :course
    low_range 0
    high_range 100000

    factory :grade_scheme_element_high do
      low_range 10000
      high_range 20000
      letter { 'A' }
      level { 'Amazing' }
    end

    factory :grade_scheme_element_low do
      low_range 0
      high_range 9999
      letter { 'F' }
      level { 'Awful' }
    end

  end
end
