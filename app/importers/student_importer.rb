require "csv"
require_relative "../services/creates_new_user"

class StudentImporter
  attr_reader :successful, :unsuccessful
  attr_accessor :file, :internal_students, :send_welcome

  def initialize(file, internal_students=false, send_welcome=false)
    @file = file
    @internal_students = internal_students
    @send_welcome = send_welcome
    @successful = []
    @unsuccessful = []
  end

  def import(course=nil)
    if file
      CSV.foreach(file, headers: true, skip_blanks: true) do |csv|
        strip_whitespace csv
        row = UserRow.new csv

        team = find_or_create_team row, course
        if team && !team.valid?
          append_unsuccessful row, team.errors.full_messages.join(", ")
          next
        end

        user = find_or_create_user row, course

        if user.valid?
          team.students << user if team
          successful << user
        else
          append_unsuccessful row, user.errors.full_messages.join(", ")
        end
      end
    end

    self
  end

  private

  def append_unsuccessful(row, errors)
    unsuccessful << { data: row.to_s, errors: errors }
  end

  def find_or_create_user(row, course)
    user = User.find_by_insensitive_email row.email.downcase if row.email
    user ||= User.find_by_insensitive_username row.username if row.username
    user ||= Services::CreatesNewUser
      .create(row.to_h.merge(internal: internal_students), send_welcome)[:user]

    if course && user.valid? && !user.is_student?(course)
      user.course_memberships.create(course_id: course.id, role: "student")
    end
    user
  end

  def find_or_create_team(row, course)
    return if row.team_name.blank?
    team = Team.find_by_course_and_name course.id, row.team_name
    team ||= Team.create course_id: course.id, name: row.team_name
  end

  def strip_whitespace(row)
    row.each_with_index { |field, index| row[index].strip! if row[index] }
  end

  class UserRow
    attr_reader :data

    def first_name
      data[0]
    end

    def last_name
      data[1]
    end

    def username
      data[2]
    end

    def email
      data[3]
    end

    def team_name
      data[4]
    end

    def password
      data[5]
    end

    def initialize(data)
      @data = data
    end

    def to_s
      data.to_s
    end

    def to_h
      {
        first_name: first_name,
        last_name: last_name,
        email: email,
        username: username,
        password: password
      }
    end
  end
end
