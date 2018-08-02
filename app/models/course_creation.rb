class CourseCreation < ApplicationRecord
  include Rails.application.routes.url_helpers
  belongs_to :course

  validates_presence_of :course

  def self.find_or_create_for_course(course_id)
    CourseCreation.find_or_create_by(course_id: course_id)
  end

  # returns the human readable version of any checklist item
  def title_for_item(item)
    case checklist_sym item
    when :settings
      "course settings"
    when :attendance
      "attendance"
    when :assignments
      "assignments"
    when :calendar
      "calendar events"
    when :instructors
      "set up teaching team"
    when :roster
      "import roster"
    when :badges
      "badges"
    when :teams
      "teams"
    end
  end

  def url_for_item(item)
    case checklist_sym item
    when :settings
      edit_course_url(self.course, only_path: true)
    when :attendance
      # add when feature is implemented
    when :assignments
      assignments_url(only_path: true)
    when :calendar
      events_url(only_path: true)
    when :instructors
      staff_index_url(only_path: true)
    when :roster
      import_users_url(only_path: true)
    when :badges
      badges_url(only_path: true)
    when :teams
      teams_url(only_path: true)
    end
  end

  # returns all boolean fields as array of checklist items
  # only adds badges and teams for courses with these items
  # attendance is ignored for now, until the feature is in place
  def checklist
    ignored_fields = ["id", "course_id", "created_at", "updated_at", "attendance_done"]
    ignored_fields << "badges_done" unless self.course.has_badges
    ignored_fields << "teams_done" unless self.course.has_teams
    self.class.columns.map(&:name) - ignored_fields
  end

  private

  # Convert column attributes into symbols for evaluating
  # example: "settings_done" => :settings
  def checklist_sym(item)
    item[0..-6].to_sym
  end
end
