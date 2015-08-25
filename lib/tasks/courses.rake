namespace :courses do
  desc "Initializes the instructors of record for all existing courses"
  task :update_instructors_of_record => :environment do
    all = []
    CourseMembership.find_each do |membership|
      membership.update_attribute :instructor_of_record, false
    end

    Course.find_each do |course|
      course_membership = course.course_memberships.where(role: "professor").first
      if course_membership
        course_membership.instructor_of_record = true
        course_membership.save
        all << course_membership
      end
    end

    puts "\nSuccessfully updates all #{all.count} #{"course".pluralize(all.count)}."
  end
end
