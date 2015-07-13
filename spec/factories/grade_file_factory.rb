FactoryGirl.define do
  factory :grade_file do
    association :grade
    filename "test_file.rb"
    filepath "uploads/grade_files/"
    file { fixture_file('test_image.jpg', 'img/jpg') }
  end
end
