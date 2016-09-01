module Submissions::GradeHistory
  def submission_grade_filtered_history(submission, grade, only_student_visible_grades=true)
    HistoryFilter.new(submission.historical_collection_merge(submission.submission_files)
      .historical_merge(grade).history)
      .merge("SubmissionFile" => "Submission")
      .remove("name" => "admin_notes")
      .remove("name" => "feedback_read")
      .remove("name" => "feedback_read_at")
      .remove("name" => "feedback_reviewed")
      .remove("name" => "feedback_reviewed_at")
      .remove("name" => "final_points")
      .remove("name" => "graded_at")
      .remove("name" => "graded_by_id")
      .remove("name" => "instructor_modified")
      .remove("name" => "score")
      .remove("name" => "status")
      .remove("name" => "submission_id")
      .remove("name" => "submitted_at")
      .remove("name" => "updated_at")
      .remove("name" => "file")
      .remove("name" => "store_dir")
      .remove("name" => "id")
      .transform do |history_item|
        if history_item.version.item_type == "SubmissionFile"
          history_item.changeset["event"] = "upload"
        end
      end
      .rename("SubmissionFile" => "Attachment")
      .include do |history_item, history|
        viewable = true

        if history_item.changeset["object"] == "Grade" && only_student_visible_grades
          version = history_item.version.reify
          viewable = GradeProctor.new(version).viewable?

          unless viewable
            # Make the change viewable if the grade was updated first but then
            # it was released. This displays the changeset where the grade was
            # updated
            viewable = (history_item.changeset.keys.include?("raw_points") ||
                        history_item.changeset.keys.include?("feedback")) &&
                        history_item.version.event == "update" &&
                        GradeProctor.new(grade).viewable?
          end
        end

        viewable
      end
      .changesets
  end
end
