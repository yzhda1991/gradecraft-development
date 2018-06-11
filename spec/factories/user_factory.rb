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

    after :stub, :build do |user, evaluator|
      # Define course_memberships with an optional role
      evaluator.courses.each do |course|
        course_membership_attributes = { course: course, user: user }
        course_membership_attributes.merge! role: evaluator.role unless evaluator.role.nil?
        create :course_membership, course_membership_attributes
      end
    end

    after(:create) { |user, evaluator| user.activate! unless evaluator.activated == false }
  end
end
