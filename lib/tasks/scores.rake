namespace :scores do

  # Usage: bundle exec rails scores:mark_grades_as_visibly_updated[10,20]
  desc "Arbitrarily update updated_at, visibility for some number of grades and \
    earned badges for load testing scheduled nightly_score_recalculator job"
  task :mark_grades_as_visibly_updated, [:grade_count, :earned_badge_count] => :environment do |task, args|
    args.with_defaults(earned_badge_count: args[:grade_count])  # if not provided, same as grade count

    grades = Grade.limit(args[:grade_count].to_i)
    earned_badges = EarnedBadge.limit(args[:earned_badge_count].to_i)
    time_within_last_day = Time.now - 2.hour

    puts "Updating the following grade IDs (#{grades.count}): \n#{grades.pluck(:id)}"
    puts "and the following earned badge IDs (#{earned_badges.count}): \n#{earned_badges.pluck(:id)}"

    grades.update updated_at: time_within_last_day, student_visible: true
    earned_badges.update updated_at: time_within_last_day, student_visible: true

    puts "Done."
  end
end
