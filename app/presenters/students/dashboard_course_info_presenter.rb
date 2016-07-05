require "./lib/showtime"

class Students::DashboardCourseInfoPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def course
    properties[:course]
  end

  def student
    properties[:student]
  end

  def has_info?
    if student
      course.instructors_of_record.present? || course.office_hours.present? || course.office.present? || course.office_hours.present? || student.team_leaders(course).present? || student.team_for_course(course).present? || course.syllabus.present? || course.phone.present? || course.class_email.present? || course.twitter_handle.present? || course.twitter_hashtag.present? || course.meeting_times.present?
    else
      course.instructors_of_record.present? || course.office_hours.present? || course.office.present? || course.office_hours.present? || course.syllabus.present? || course.phone.present? || course.class_email.present? || course.twitter_handle.present? || course.twitter_hashtag.present? || course.meeting_times.present?
    end
  end
end