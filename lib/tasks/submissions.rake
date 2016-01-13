namespace :submissions do
  desc "Update all of the submitted_at dates to the updated_at for the submissions"
  task :update_submitted_at => :environment do
    Submission.all.each { |s| s.update_attributes(submitted_at: s.updated_at) }
  end
end
