FactoryGirl.define do
  factory :event do
    name { Faker::Lorem.word }
    description ""
    open_at ""
    due_at ""
    media ""
    thumbnail ""
    media_credit ""
    media_caption "MyString"
  end
end
