module SubmissionsHelper
  def resubmission_count_for(course)
    Rails.cache.fetch(resubmission_count_cache_key(course)) do
      course.submissions.resubmitted.count
    end
  end

  def resubmission_count_cache_key(course)
    "#{course.cache_key}/resubmission_count"
  end

  def ungraded_submissions_count_for(course, include_drafts=false)
    Rails.cache.fetch(ungraded_submissions_count_cache_key(course)) do
      if include_drafts
        course.submissions.ungraded.count
      else
        course.submissions.submitted_by_active_students.ungraded.count
      end
    end
  end

  def ungraded_submissions_count_cache_key(course)
    "#{course.cache_key}/ungraded_submissions_count"
  end
end
