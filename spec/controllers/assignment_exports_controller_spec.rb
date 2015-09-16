require 'spec_helper'

RSpec.describe AssignmentExportsController, type: :controller do
  context "as a professor" do
    before do
      @course = create(:course_accepting_groups)
      create_professor_for_course(@course)
      create_assignment_for_course(@course)
      create_students_for_course(@course, 2)

      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

    describe "GET export_submissions", working: true do
      context "relevant students" do
        it "gets all students for the course" do
          pending   
        end

        it "should equal the size of the class" do
          pending
        end
      end
    end

    describe "GET export_team_submissions", working: true do
      context "students on active team" do
        it "gets students on the active team" do
          pending
        end

        it "does not included students from other team" do
          pending
        end

        it "should have as many students as the active team" do
          pending
        end
      end
    end

  end

  # helper methods
  def create_students_for_course(course, total)
    total.times do |n|
      n += 1
      self.instance_variable_set("@student#{n}", create(:user))
      active_student = self.instance_variable_get("@student#{n}")
      CourseMembership.create user_id: active_student[:id], course_id: @course[:id], role: "student"
    end
  end

  def create_professor_for_course(course)
    @professor = create(:user)
    CourseMembership.create user_id: @professor[:id], course_id: @course[:id], role: "professor"
  end

  def create_assignment_for_course(course)
    @assignment_type = create(:assignment_type, course: course)
    @assignment = create(:assignment, assignment_type: @assignment_type, course: course)
  end
end
