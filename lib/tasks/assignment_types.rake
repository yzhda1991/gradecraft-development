namespace :assignment_types do
  desc "Set all assignment types with a max_points value of nil to zero"
  task update_max_points: :environment do
    AssignmentType.where("max_points IS NULL").update_all(max_points: 0)
  end
end
