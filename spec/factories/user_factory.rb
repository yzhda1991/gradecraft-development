FactoryBot.define do
  factory :user do
    transient do
      courses []
      role nil
      activated true
    end

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Internet.unique.user_name }
    email { Faker::Internet.unique.email }
    password { "secret" }

    after :create do |user, evaluator|
      evaluator.courses.each do |course|
        create :course_membership, { course: course, user: user, role: evaluator.role }
      end
      user.activate! unless evaluator.activated == false
    end
  end
end
