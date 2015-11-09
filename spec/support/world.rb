class World
  def self.create
    Instance.new
  end

  class Instance
    attr_reader :courses, :course_memberships, :users

    def course
      courses.first
    end

    def students
      course_memberships.select{ |cm| cm.role == "student" }.map(&:user)
    end

    def student
      students.first
    end

    def user
      users.first
    end

    def create_course(attributes={})
      courses << FactoryGirl.create(:course, attributes)
      self
    end

    def create_student(attributes={})
      course = attributes.delete(:course) || self.course
      user = FactoryGirl.create(:user, attributes)
      course_memberships << FactoryGirl.create(:course_membership, course: course, user: user, role: "student") if course
      users << user
      self
    end

    private

    def initialize
      @courses = []
      @course_memberships = []
      @users = []
    end
  end
end
