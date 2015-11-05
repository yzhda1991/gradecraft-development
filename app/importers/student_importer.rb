require 'csv'

class StudentImporter
  attr_reader :successful, :unsuccessful
  attr_accessor :file, :internal_students

  def initialize(file, internal_students=false)
    @file = file
    @internal_students = internal_students
    @successful = []
    @unsuccessful = []
  end

  def import(course=nil)
    if file
      CSV.foreach(file, headers: true, skip_blanks: true) do |row|
        team = find_or_create_team row, course
        if team && !team.valid?
          append_unsuccessful row, team.errors.full_messages.join(", ")
          next
        end

        user = find_or_create_user row, course

        if user.valid?
          team.students << user if team
          UserMailer.activation_needed_email(user).deliver_now unless user.activated?
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
    email = row[3]

    user = User.find_by_insensitive_email email
    user ||= User.create do |u|
      u.first_name = row[0]
      u.last_name = row[1]
      u.username = row[2]
      u.email = row[3]
      if row[5].present?
        u.password = row[5]
      else
        u.password = generate_random_password
      end
    end

    user.course_memberships.create(course_id: course.id, role: "student") if course
    user
  end

  def find_or_create_team(row, course)
    name = row[4]
    return if name.blank?
    team = Team.find_by_course_and_name course.id, name
    team ||= Team.create course_id: course.id, name: name
  end

  def generate_random_password
    Sorcery::Model::TemporaryToken.generate_random_token
  end
end
