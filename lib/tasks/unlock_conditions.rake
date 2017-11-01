namespace :unlock_conditions do
  # Affected condition: Unlock conditions were being linked to
  # Unlockable models: assignments, badges, grade scheme elements
  # Unlock condition types: assignments, assignment_types, badges, courses
  #
  # Usage: rails "unlock_conditions:find_errant_conditions_for_course[course_id]"
  desc "check for a particular course how many errant unlock conditions there are"
  task :find_errant_conditions_for_course, [:course_id] => [:environment] do |task, args|
    course = Course.find args[:course_id]
    unlockable_model_associations = [:assignments, :badges, :grade_scheme_elements].freeze

    unlockable_model_associations.each do |a|
      # Fetch unlock conditions for the condition_type, for the course
      unlocks = course.public_send(a).map(&:unlock_conditions).flatten

      # Unlock conditions that reference a condition type that doesn't belong to the current course
      invalid_unlocks = unlocks.select do |u|
        course.public_send(u.condition_type.downcase.pluralize).where(id: u.condition_id).empty?
      end

      puts "> #{a.to_s.singularize} ids with unlock conditions that don't exist for course, \"#{course.name}\""
      puts "(#{invalid_unlocks.count}): #{invalid_unlocks}"
    end
  end
end
