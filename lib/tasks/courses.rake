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

  desc "Updates all the administrators in the system to have access to all courses"
  task :update_admins => :environment do
    courses = Course.all
    CourseMembership.where(role: "admin").select(:user_id).uniq.each do |membership|
      user = User.find membership.user_id
      user.admin = true
      user.save
      courses.each do |course|
        if !CourseMembership.where(user_id: user.id, role: "admin").exists?
          CourseMembership.create! course_id: course.id, user_id: user.id, role: "admin"
        end
      end
    end
  end
end
