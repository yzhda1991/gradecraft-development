namespace :db do
  task :reset_test_envs, [:test_db_count] => :environment do |t, args|
    test_db_total = 1
    test_db_total += args[:test_db_count].to_i if args[:test_db_count]

    puts "Resetting the schemas for #{test_db_total} test databases.."

    puts "Using the default test environment..."
    ENV["RAILS_ENV"] = "test"

    puts "resetting schema for default test database..."
    Rake::Task["db:reset"].invoke

    (1..args[:test_db_count].to_i).each do |db_number|
      puts "Using test environment ##{db_number}"
      ENV["TEST_ENV_NUMBER"] = "#{db_number}"

      puts "resetting schema for test environment ##{db_number}"
      Rake::Task["db:reset"].invoke
    end
  end
end
