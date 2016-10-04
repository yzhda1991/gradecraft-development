require_relative "../../services/creates_new_user"

class CanvasStudentImporter
  attr_reader :successful, :unsuccessful
  attr_accessor :send_welcome, :students

  def initialize(students, send_welcome=false)
    @students = students
    @send_welcome = send_welcome
    @successful = []
    @unsuccessful = []
  end

  def import(course)
    unless students.nil?
      students.each do |canvas_student|
        user = find_or_create_user UserRow.new(canvas_student), course

        if user.valid?
          link_imported canvas_student["id"], user
          successful << user
        else
          unsuccessful << { data: canvas_student,
                            errors: user.errors.full_messages.join(", ") }
        end
      end
    end

    self
  end

  private

  def find_or_create_user(row, course)
    user = User.find_by_insensitive_email row.email if row.email
    user ||= Services::CreatesNewUser
      .create(row.to_h.merge(internal: false), send_welcome)[:user]

    if user.valid? && !user.is_student?(course)
      user.course_memberships.create(course_id: course.id, role: :student)
    end

    user
  end

  def link_imported(provider_resource_id, user)
    imported = ImportedUser.find_or_initialize_by(provider: :canvas,
      provider_resource_id: provider_resource_id)
    imported.user = user
    imported.last_imported_at = DateTime.now
    imported.save
  end

  class UserRow
    attr_reader :data

    def first_name
      (data["name"] || "").split.first.strip
    end

    def last_name
      (data["name"] || "").split.last.strip
    end

    def email
      data["primary_email"]
    end

    def initialize(data)
      @data = data
    end

    def to_h
      {
        first_name: first_name,
        last_name: last_name,
        email: email
      }
    end
  end
end
