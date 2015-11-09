class World
  def self.create
    Instance.new
  end

  class Instance
    attr_reader :assignments, :courses, :course_memberships, :grades, :users

    def assignment
      assignments.first
    end

    def course
      courses.first
    end

    def grade
      grades.first
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

    def create_assignment(attributes={})
      course = attributes.delete(:course) || self.course || FactoryGirl.build(:course)
      assignments << FactoryGirl.create(:assignment, attributes.merge(course: course))
      self
    end

    def create_course(attributes={})
      courses << FactoryGirl.create(:course, attributes)
      self
    end

    def create_grade(attributes={})
      assignment = attributes.delete(:assignment) || self.assignment || FactoryGirl.build(:assignment)
      assignment_type = attributes.delete(:assignment_type) || assignment.assignment_type
      course = attributes.delete(:course) || self.course || FactoryGirl.build(:course)
      student = attributes.delete(:student) || self.student || FactoryGirl.build(:user)
      grades << FactoryGirl.create(:grade, attributes.merge(assignment: assignment, assignment_type: assignment_type,
                                                            course: course, student: student))
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
      @assignments = []
      @courses = []
      @course_memberships = []
      @grades = []
      @users = []
    end
  end
end
