namespace :users do
  desc "Activates all existing users"
  task :activate => :environment do
    all = User.all
    all.each(&:activate!)
    puts "\nSuccessfully activated all #{all.count} #{"user".pluralize(all.count)}."
  end

  namespace :set do
    desc "Set all user passwords to a common one for testing purposes"
    task :master_password => :environment do
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
      task password.to_sym do ; end
    end
  end

  desc "Set all user passwords to 'waffles' for testing purposes"
  task :waffleize => :environment do
    User.update_all crypted_password: "9ba2d402d1dfe11f8c90e0edd10dba2fae2a246a"
    puts "All users have been waffleized."
  end

  desc "Activate all users"
  task :activate_all => :environment do
    User.update_all  active: true
    puts "All users have been waffleized."
  end
end
