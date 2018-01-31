namespace :unlocks do
  desc "Updates course id on unlocks created before belongs_to course was added"
  task add_course_ids: :environment do
    UnlockCondition.find_each(batch_size: 500) do |uc|
      next if uc.course.present?
      # unlockable should be limited to badge and assignment
      # both of which have a course_id
      uc.course_id = uc.unlockable.course_id
      puts "updated condition #{uc.id}" if uc.save
    end
  end
end
