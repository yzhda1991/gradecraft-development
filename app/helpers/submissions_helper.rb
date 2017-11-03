module SubmissionsHelper
  def resubmission_count_for(course)
    Rails.cache.fetch(resubmission_count_cache_key(course)) do
      active_individual_and_group_submissions(course.submissions.submitted.resubmitted).count
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
    submissions.by_active_individual_students + submissions.by_active_grouped_students
  end
end
