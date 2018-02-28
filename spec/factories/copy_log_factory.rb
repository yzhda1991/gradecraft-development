FactoryGirl.define do
  factory :copy_log do
    association :course
    log "{:courses=>{1=>2}}"
  end
end
