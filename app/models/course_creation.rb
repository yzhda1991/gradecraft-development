class CourseCreation < ActiveRecord::Base
  belongs_to :course

  validates_presence_of :course

  def self.find_or_create_for_course(course_id)
    CourseCreation.find_or_create_by(course_id: course_id)
  end

  # returns the human readable version of any checklist item
  def title_for_item(item)
    # settings_done => :settings
    case item[0..-6].to_sym
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

  # returns all boolean fields as array of checklist items
  def checklist
    ignored_fields = ["id", "course_id", "created_at", "updated_at"]
    ignored_fields << "badges_done" unless self.course.has_badges
    ignored_fields << "teams_done" unless self.course.has_teams
    self.class.columns.map(&:name) - ignored_fields
  end
end



