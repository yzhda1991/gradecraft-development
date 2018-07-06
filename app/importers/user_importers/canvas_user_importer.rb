require_relative "../../services/creates_new_user"

class CanvasUserImporter
  attr_reader :successful, :unsuccessful, :unchanged
  attr_accessor :send_welcome, :users

  def initialize(users, send_welcome=false)
    @users = users
    @send_welcome = send_welcome
    @successful = []
    @unsuccessful = []
    @unchanged = []
  end

  def import(course)
    unless users.nil?
      users.each do |canvas_user|
        result = find_or_create_user UserRow.new(canvas_user), course
        user = result[:user]

        if user.valid?
          link_imported canvas_user["id"], user
          if !result[:changed?]
            unchanged << user
          else
            successful << user
          end
        else
          unsuccessful << { data: canvas_user,
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
      .call(row.to_h.merge(internal: false), send_welcome)[:user]
    role_changed = false

    if user.valid?
      current_role = user.role(course)
      if current_role.nil?
        user.course_memberships.create(course_id: course.id, role: row.role)
        role_changed = true
      elsif current_role != row.role
        cm = user.course_memberships.find_by(course_id: course.id)
        role_changed = cm.update(role: row.role)
      end
    end

    { user: user, changed?: !user.previous_changes.empty? || role_changed }
  end

  def link_imported(provider_resource_id, user)
    imported = ImportedUser.find_or_initialize_by(provider: :canvas,
      provider_resource_id: provider_resource_id)
    imported.user = user
    imported.last_imported_at = DateTime.now
    imported.save
  end

  class UserRow
    include CanvasAPIHelper

    attr_reader :data

    def first_name
      (data["name"] || "").split.first.strip
    end

    def last_name
      (data["name"] || "").split.last.strip
    end

    def email
      data["primary_email"] || data["email"]
    end

    def role
      enrollments = data["enrollments"]
      return "student" if enrollments.nil?
      lms_user_role enrollments
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
