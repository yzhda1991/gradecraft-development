require 'csv'

class UserImporter
  attr_reader :successful, :unsuccessful
  attr_accessor :file

  def initialize(file)
    @file = file
    @successful = []
    @unsuccessful = []
  end

  def import(course=nil)
    if file
      CSV.foreach(file, headers: true, skip_blanks: true) do |row|
        user = create_user row, course
      end
    end

    self
  end

  private

  def create_user(row, course)
    user = User.create do |u|
      u.first_name = row[0]
      u.last_name = row[1]
      u.username = row[2]
      u.email = row[3]
      u.password = generate_random_password
      u.course_memberships.build(course_id: course.id, role: "student") if course
    end
  end

  def generate_random_password
    Sorcery::Model::TemporaryToken.generate_random_token
  end
end
