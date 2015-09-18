require 'spec_helper'

describe AssignmentExportsController do

  # include rspec helper methods for assignments
  include AssignmentsToolkit

  context "as a professor" do
    before(:each) do
      clear_rails_cache
      setup_submissions_environment_with_users

      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

    describe "GET export_submissions" do
      before do
        # create an instance of the controller for testing private methods
        @controller = AssignmentExportsController.new

        @student1 = {first_name: "Ben", last_name: "Bailey", id: 40}
        @student2 = {first_name: "Mike", last_name: "McCaffrey", id: 55}
        @student3 = {first_name: "Dana", last_name: "Dafferty", id: 92}

        # create some mock submissions with students attached
        @submission1 = {id: 1, student: @student1}
        @submission2 = {id: 2, student: @student2}
        @submission3 = {id: 3, student: @student3}
        @submission4 = {id: 4, student: @student2}

        @submissions = [@submission1, @submission2, @submission3, @submission4]

        # expectation for #group_submissions_by_student
        @grouped_submission_expectation = {
          "bailey_ben-40" => [@submission1],
          "mccaffrey_mike-55" => [@submission2, @submission4],
          "dafferty_dana-92" => [@submission3]
        }

        @controller.instance_variable_set("@submissions", @submissions)
      end

      context "grouping students" do
        it "should group students by 'last_name_first_name-id'" do
          # finally expect something to happen
          expect(@controller.instance_eval { group_submissions_by_student }).to eq(@grouped_submission_expectation)
        end
      end
    end

    context "export requests" do
      describe "before filter" do
        it "should query for the assignment by :assignment_id" do
          expect(Assignment).to receive(:find).with(@assignment[:id].to_s).and_return (@assignment)
          get :submissions, { assignment_id: @assignment[:id], format: "json" }
        end

        it "should return the assignment" do
          # create an instance of the controller for testing private methods
          @controller = AssignmentExportsController.new
          allow(@controller).to receive(:params).and_return ({assignment_id: @assignment[:id]})
          expect(@controller.instance_eval { fetch_assignment }).to eq(@assignment)
        end
      end

      describe "GET submissions" do
        it "should set the correct assignment" do
          expect(assigns(:assignment)).to eq(@assignment)
        end

        it "should set the expected value for submissions" do
          # add @assignment and @submissions as doubles
          create_doubles_with_ivars(Assignment, "Submissions")
          stub_assignment_fetcher

          allow(@assignment).to receive(:student_submissions).and_return(@submissions)

          get :submissions, { assignment_id: 50, format: "json" }
          expect(assigns(:submissions)).to eq(@submissions)
        end

        it "should restrict access to professors for that class" do
        end
      end

      describe "GET submissions_by_team", working: true do
        it "should set the correct assignment" do
          expect(assigns(:assignment)).to eq(@assignment)
        end

        it "should set the expected value for submissions", focus: true do
          # add @assignment and @submissions as doubles
          create_doubles_with_ivars("Assignment", "Submissions", "Team")
          stub_assignment_fetcher

          allow(Team).to receive(:find).and_return(@team)
          allow(@assignment).to receive(:student_submissions_for_team).with(900).and_return(@submissions)

          get :submissions_by_team, { assignment_id: 50, team_id: 900, format: "json"}
          expect(assigns(:submissions)).to eq(@submissions)
        end

        it "should restrict access to professors for that class" do
        end
      end
    end

    def get_submissions
      get :submissions, { assignment_id: @assignment[:id], format: "json" }
    end

    def stub_assignment_fetcher
      allow(Assignment).to receive(:find).and_return(@assignment)
    end
  end
end
