require "./lib/showtime"

class Navigation::CourseInfoPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def course
    properties[:course]
  end

  def student
    properties[:student]
  end

  def has_info?
    if student
      has_student_info? || has_course_info?
    else
      has_course_info?
    end
  end

  private

  def has_student_info?
    student.team_leaders(course).present? || student.team_for_course(course).present?
  end

  def has_course_info?
    [:instructors_of_record, :office_hours, :office, :office_hours, :syllabus,
     :phone, :class_email, :twitter_handle, :twitter_hashtag, :meeting_times
    ].any? { |attr| course[attr].present? }
  end
end
