FactoryGirl.define do
  factory :submission_file do
    association :submission
    filename "test_file.rb"
    file { fixture_file("test_image.jpg", "img/jpg") }

    factory :confirmed_submission_file do
      last_confirmed_at Time.now
    end

    factory :unconfirmed_submission_file do
      last_confirmed_at nil
    end

    factory :missing_submission_file do
      file_missing true
    end

    factory :present_submission_file do
      file_missing false
    end
  end
end
