FactoryGirl.define do
  factory :user do
    transient do
      courses []
      role nil
    end

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Internet.user_name }
    email { Faker::Internet.email }
    password { "secret" }

    # Define course_memberships with an optional role
    after :stub, :build do |user, evaluator|
      evaluator.courses.each do |course|
        course_membership_attributes = { course: course, user: user }
        course_membership_attributes.merge! role: evaluator.role unless evaluator.role.nil?
        create :course_membership, course_membership_attributes
      end
    end

    after :create, &:activate!
  end
end
