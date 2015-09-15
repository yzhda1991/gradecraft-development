require 'rails_helper'

RSpec.describe AssignmentExportsController, type: :controller do
  context "as a professor" do
    before do
      @course = create(:course_accepting_groups)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @assignment_type = create(:assignment_type, course: @course)
      @assignment = create(:assignment, assignment_type: @assignment_type)
      @course.assignments << @assignment
      @student = create(:user)
      @student.courses << @course

      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

    describe "GET export_submissions", working: true do
      before do
        @course = create(:course_accepting_groups)
        create_professor_for_course(@course)
        @assignment_type = create(:assignment_type, course: @course)
        @assignment = create(:assignment, assignment_type: @assignment_type)
        @course.assignments << @assignment
        create_students_for_course(@course, 2)
      end

      context "relevant students" do
        it "gets all students for the course" do
        end

        it "should equal the size of the class" do
        end
      end
    end

    describe "GET export_team_submissions", working: true do
      context "students on active team" do
        it "gets students on the active team" do
        end

        it "does not included students from other team" do
        end

        it "should have as many students as the active team" do
        end
      end
    end

  end

  # helper methods
  def create_students_for_course(course, total)
    total.times do |n|
      self.instance_variable_set("student#{n}", create(:student))
      active_student = self.instance_variable_get("student#{n}")
      CourseMembership.create user_id: active_student[:id], course_id: @course[:id], role: "student"
    end
  end

  def create_professor_for_course(course)
    @professor = create(:user)
    CourseMembership.create user_id: @professor[:id], course_id: @course[:id], role: "professor"
  end
end
