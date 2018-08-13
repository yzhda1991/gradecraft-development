namespace :assignments do
  desc "Sets student_logged to false if grade_scope == 'Group'"
  task validate_if_student_logged: :environment do
    assignments = Assignment.where(student_logged: true, grade_scope: "Group")

    puts "Found #{assignments.length} assignments to fix."
    assignments.find_in_batches(batch_size: 500) do |ag|
      ag.update! student_logged: false
    end
    puts "Done!"
  end
end
