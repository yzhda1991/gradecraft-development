module SubmissionsHelper
  def resubmission_count_for(course)
    Rails.cache.fetch(resubmission_count_cache_key(course)) do
      active_individual_and_group_submissions(course.submissions.submitted.resubmitted).count
      # active_individual_and_group_submissions(course.submissions.submitted.resubmission?).count
    end
  end

  def resubmission_count_cache_key(course)
    "#{course.cache_key}/resubmission_count"
  end

  def ungraded_submissions_count_for(course, include_drafts=false)
    Rails.cache.fetch(ungraded_submissions_count_cache_key(course)) do
      if include_drafts
        active_individual_and_group_submissions(course.submissions.ungraded).count
      else
        active_individual_and_group_submissions(course.submissions.submitted.ungraded).count
      end
    end
  end

  def ungraded_submissions_count_cache_key(course)
    "#{course.cache_key}/ungraded_submissions_count"
  end

  def active_individual_and_group_submissions(submissions)
    submissions.by_active_individual_students + Submission.by_active_grouped_students(submissions)
  end

  # Returns a link that directs the current_user to a submission
  # Could be a link to create the submission, to edit an existing submitted or draft submission,
  # or to just see a submitted submission
  def submission_link_to(assignment, student=current_student)
    link = nil
    submission = submission_for assignment, student

    if submission.nil?
      return unless allows_new_submissions? assignment, student
      link = link_to glyph(:upload) + "Submit", submit_assignment_submission_path(assignment, student), class: "button"
    else
      sp = SubmissionProctor.new(submission)
      return unless sp.viewable? current_user

      if sp.open_for_editing? assignment, current_user
        text = submission.term_for_edit current_user_is_staff?
        link = link_to glyph(:pencil) + text, edit_assignment_submission_path(assignment, id: submission.id), class: "button"
      else
        link = link_to glyph(:"file-o") + "See Submission", see_submission_path(submission), class: "button"
      end
    end

    link
  end

  private

  def submission_for(assignment, student)
    if assignment.is_individual?
      Submission.for_assignment_and_student(assignment.id, student.id).first
    else
      group = student.group_for_assignment assignment
      return nil if group.nil?
      group.submission_for_assignment(assignment)
    end
  end

  # Assignment allows new submissions if:
  # 1. The assignment is open and the course active
  # 2. Student belongs to an assignment group and the group is approved
  # 3. The assignment is unlocked for the student or group
  def allows_new_submissions?(assignment, student)
    return false unless assignment.open? && current_course.active? && assignment.is_unlocked_for_student?(student)
    if !assignment.is_individual? # group-graded assignment
      group = student.group_for_assignment assignment
      return false if group.nil? || !group.approved? || !assignment.is_unlocked_for_group?(group)
    end
    true
  end

  def see_submission_path(submission)
    assignment = submission.assignment

    if assignment.is_individual?
      current_user_is_student? ? assignment_path(assignment.id) : assignment_submission_path(assignment.id, submission.id)
    else
      assignment_path(assignment.id)
    end
  end

  def submit_assignment_submission_path(assignment, student)
    params = { assignment_id: assignment.id }
    assignment.is_individual? ? params.merge!(student_id: student.id) : params.merge!(group_id: student.group_for_assignment(assignment))
    new_assignment_submission_path(params)
  end
end
