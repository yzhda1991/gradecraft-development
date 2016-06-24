namespace :assignments do
  desc "Set assignments without a submission setting to not accept submissions"
  task update_accepts_submissions: :environment do
    Assignment.where("accepts_submissions IS NULL").update_all(accepts_submissions: false)
  end

  desc "Set assignments without a student_logged setting to be false"
  task update_student_logged: :environment do
    Assignment.where("student_logged IS NULL").update_all(student_logged: false)
  end

  desc "Set assignments without a resubmission setting to be false"
  task update_resubmissions_allowed: :environment do
    Assignment.where("resubmissions_allowed IS NULL").update_all(resubmissions_allowed: false)
  end

  desc "Set assignments without a hide_analytics setting to be false"
  task update_hide_analytics: :environment do
    Assignment.where("hide_analytics IS NULL").update_all(hide_analytics: false)
  end
end
