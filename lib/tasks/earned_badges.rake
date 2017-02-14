namespace :earned_badges do
  desc "Update all of the EarnedBadge awarded_by users to the first professors on the course"
  task update_awarded_by: :environment do
    EarnedBadge.find_each(batch_size: 500) do |e|
      if e.awarded_by == nil
        e.update_column :awarded_by_id, e.course.professors.first.id
      end
    end
  end
end

# TODO: create a new migration to make awarded_by_id NOT NULL after running this task
