namespace :users do
  desc "Activates all existing users"
  task activate: :environment do
    all = User.all
    all.each(&:activate!)
    puts "\nSuccessfully activated all #{all.count} #{"user".pluralize(all.count)}."
  end

  namespace :set do
    desc "Set all user passwords to a common one for testing purposes"
    task master_password: :environment do
      password = ARGV.last
      puts "Setting master password for all users"

      User.all.each do |user|
        if user.change_password!(password)
          print "."
        else
          print "x"
        end
      end

      puts "\nSuccessfully set master password to '#{password}'"
      task password.to_sym do; end
    end
  end

  desc "Set all user passwords to 'waffles' for testing purposes"
  task waffleize: :environment do
    u = User.where(email: "dumbledore@hogwarts.edu").first
    u.update_attributes password: "waffles", password_confirmation: "waffles"
    User.update_all crypted_password: u.crypted_password, salt: u.salt
    puts "All users have been waffleized."
  end

  desc "Activate all users"
  task activate_all: :environment do
    User.update_all active: true
    puts "All users have been activated."
  end

  desc "Make given user an admin on all courses"
  task make_admin_on_all_courses: :environment do
    if ENV['username'].nil?
      fail 'ERROR: missing username. Append the username as a variable to this task, e.g. rake users:make_admin_on_all_courses username=<username>'
    end

    user = User.find_by username: ENV['username']
    if user.nil?
      fail "ERROR: username not found (\"#{ENV['username']}\")"
    end

    Course.find_each(batch_size: 500) do |course|
      membership = CourseMembership.find_or_create_by course: course, user: user
      membership.role = 'admin'
      membership.save
      puts "Made #{user.username} an admin on \"#{course.name}\""
    end
  end
end
