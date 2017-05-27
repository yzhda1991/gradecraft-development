namespace :rubrics do

  desc "add course ids to all rubrics without them"
  task add_course_id: :environment do
    Rubric.where("course_id is NULL").find_each(batch_size: 500) do |rubric|
      rubric.update(course_id: rubric.assignment.course_id)
    end
  end
end
