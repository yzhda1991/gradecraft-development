namespace :grades do

  desc "Set all grades that have a status as being instructor_modified"

  task update_instructor_modified: :environment do
    puts "Setting grades as 'instructor_modified where a status exists..."
    total_updated = Grade.where("status is not null").update_all(instructor_modified: true)
    puts "Updated #{total_updated} grades with instructor_modified: true"
    puts "DONE"
  end

  desc "Update all of the graded_at dates to the updated_at for the grades"
  task update_graded_at: :environment do
    Grade.where("(predicted_score > 0 OR predicted_score IS NULL) AND graded_at IS NULL").update_all("graded_at=updated_at")
  end

  desc "Update grades without a final score to use raw score"
  task update_final_score: :environment do
    Grade.where("final_score is NULL and raw_score is not NULL").update_all("final_score=raw_score")
  end

  desc "Transfer the predictions off existing grades"
  task transfer_predictions: :environment do
    Grade.where("predicted_score > 0").find_each(batch_size: 500) do |grade|
      prediction = PredictedEarnedGrade.find_or_create_by(
        assignment_id: grade.assignment.id,
        student_id: grade.student.id
      )
      prediction.predicted_points = grade.predicted_score
      prediction.save
    end
  end

  desc "Update complete and student_visible fields on existing grades"
  task update_status_fields: :environment do
    Grade.find_each(batch_size: 500) do |grade|
      complete = false
      student_visible = false

      if grade.status == "In Progress"
        complete = false
        student_visible = false
      elsif grade.status == "Graded"
        if grade.assignment.release_necessary
          complete = true
          student_visible = false
        else
          complete = true
          student_visible = true
        end
      elsif grade.status == "Released"
        complete = true
        student_visible = true
      end
      grade.update_attribute(:complete, complete) if complete
      grade.update_attribute(:student_visible, student_visible) if student_visible
      puts "#{grade.id}: status: #{grade.status}, complete: #{grade.complete}, student_visible: #{grade.student_visible}"
    end
  end

  desc "Update existing grades where assignments have a new assignment type"
  task resolve_errant_assignment_types: :environment do
    resolved = []
    Grade.includes(assignment: :assignment_type).find_each(batch_size: 2000) do |grade|
      if grade.assignment_type_id != grade.assignment.assignment_type_id
        puts "Grade id: #{grade.id} (assignment_type_id #{grade.assignment_type_id} -> #{grade.assignment.assignment_type_id})"
        resolved << grade.update(assignment_type_id: grade.assignment.assignment_type_id)
      end
    end
    puts "Resolved #{resolved.count} grade(s)"
  end
end
