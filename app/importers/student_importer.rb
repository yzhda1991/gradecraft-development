require 'csv'

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
        row = UserRow.new csv

        team = find_or_create_team row, course
        if team && !team.valid?
          append_unsuccessful row, team.errors.full_messages.join(", ")
          next
        end

        user = find_or_create_user row, course

        if user.valid?
          team.students << user if team
          UserMailer.activation_needed_email(user).deliver_now unless user.activated?
          UserMailer.welcome_email(user).deliver_now if user.activated? && send_welcome
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
    user = User.find_by_insensitive_email row.email if row.email
    user ||= User.find_by_insensitive_username row.username if row.username
    user ||= User.create do |u|
      u.first_name = row.first_name
      u.last_name = row.last_name
      u.username = row.username || (username_from_email(row.email) if internal_students)
      u.email = row.email || (email_from_username(row.username) if internal_students)
      u.password = row.has_password? ? row.password : generate_random_password unless internal_students
    end
    user.activate! if user.valid? && !user.activated? && internal_students

    user.course_memberships.create(course_id: course.id, role: "student") if course && user.valid?
    user
  end

  def find_or_create_team(row, course)
    return if row.team_name.blank?
    team = Team.find_by_course_and_name course.id, row.team_name
    team ||= Team.create course_id: course.id, name: row.team_name
  end

  def generate_random_password
    Sorcery::Model::TemporaryToken.generate_random_token
  end

  def email_from_username(username)
    "#{username}@umich.edu"
  end

  def username_from_email(email)
    email.split(/@/).first
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

    def has_password?
      password.present?
    end

    def initialize(data)
      @data = data
    end

    def to_s
      data.to_s
    end
  end
end
