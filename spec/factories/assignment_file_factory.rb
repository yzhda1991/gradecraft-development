FactoryBot.define do
  factory :assignment_file do
    association :assignment
    filename "test_file.rb"
    file { fixture_file("test_image.jpg", "img/jpg") }
  end
end
