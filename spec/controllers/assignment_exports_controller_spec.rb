require 'spec_helper'

RSpec.describe AssignmentExportsController, type: :controller do

  # include rspec helpers for assignments
  include AssignmentsToolkit

  context "as a professor" do
    before do
      @course = create(:course_accepting_groups)
      @students = []
      create_professor_for_course
      create_assignment_for_course
      create_students_for_course(2)

      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

    describe "GET export_submissions", working: true do
      before(:each) do
        @controller = AssignmentExportsController.new

        @submission1 = {id: 1, student: 
          {first_name: "Ben", last_name: "Bailey", id: 40}}
        @submission2 = {id: 2, student:
          {first_name: "Mike", last_name: "McCaffrey", id: 55}}
        @submission3 = {id: 3, student:
          {first_name: "Dana", last_name: "Dafferty", id: 92}}
        @submission4 = {id: 4, student:
          {first_name: "Mike", last_name: "McCaffrey", id: 55}}

        @submissions = [@submission1, @submission2, @submission3, @submission4]

        @grouped_submission_expectation = {
          "bailey_ben-40" => [@submission1],
          "mccaffrey_mike-55" => [@submission2, @submission4],
          "dafferty_dana-92" => [@submission3]
        }

        @controller.instance_variable_set("@submissions", @submissions)
      end

      context "grouping students" do
        it "should group students by 'last_name_first_name-id'" do
          expect(@controller.instance_eval { group_submissions_by_student }).to eq(@grouped_submission_expectation)
        end
      end
    end

    describe "GET export_team_submissions", working: true do
      context "students on active team" do
        it "gets students on the active team" do
          skip
        end

        it "does not included students from other team" do
          skip
        end

        it "should have as many students as the active team" do
          skip
        end
      end
    end
  end

end
