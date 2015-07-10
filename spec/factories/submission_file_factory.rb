FactoryGirl.define do
  factory :submission_file do
    association :submission
    filename "test_file.rb"
    filepath "uploads/submission_files/"
    file { fixture_file('test_image.jpg', 'img/jpg') }
  end
end
