module SubmissionsHelper
  def resubmission_count_for(course)
    Rails.cache.fetch(resubmission_count_cache_key(course)) do
      course.submissions.resubmitted.count
    end
  end

  def resubmission_count_cache_key(course)
    "#{course.cache_key}/resubmission_count"
  end

  def ungraded_submissions_count_for(course)
    Rails.cache.fetch(ungraded_submissions_count_cache_key(course)) do
      course.submissions.ungraded.count
    end
  end

  def ungraded_submissions_count_cache_key(course)
    "#{course.cache_key}/ungraded_submissions_count"
  end
end
