require 'spec_helper'

RSpec.describe AssignmentExportsController, type: :controller do

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

    context "export requests" do
      describe "before filter" do
        it "should query for the assignment by :assignment_id" do
          request_get_submissions
          expect(Assignment).to receive(:find).with(@assignment[:id].to_s).and_return (@assignment)
        end

        it "should return the assignment" do
          # create an instance of the controller for testing private methods
          @controller = AssignmentExportsController.new
          allow(@controller).to receive(:params).and_return ({assignment_id: @assignment[:id]})
          expect(@controller.instance_eval { fetch_assignment }).to eq(@assignment)
        end
      end

      describe "GET submissions", working: true do
        it "should set the correct assignment" do
          request_get_submissions
          expect(assigns(:assignment)).to eq(@assignment)
        end

        it "should build and set an AssignmentExportPresenter" do
          request_get_submissions
          expect(assigns(:presenter).class).to eql(AssignmentExportPresenter)
        end

        it" should build a new presenter and pass submissions to it", focus: true do
          request_get_submissions
          allow(AssignmentExportPresenter).to receive(:new).with(assigns(:assignment).student_submissions)
        end

        it "should set the expected value for submissions" do
          # add @assignment and @submissions as doubles
          create_doubles_with_ivars(Assignment, "Submissions")
          allow(Assignment).to receive(:find).and_return(@assignment)
          allow(@assignment).to receive(:student_submissions).and_return(@submissions)

          get :submissions, { assignment_id: 50, format: "json" }
        end

        describe "authorizations" do
          before(:each) do
            clear_rails_cache
            setup_submissions_environment_with_users
          end

          context "student makes request" do
            it "should redirect to the homepage" do
              logout_user # logout professor
              login_user(@student1) # login student
              request_get_submissions
              expect(response).to redirect_to(root_url)
            end
          end

          context "staff makes request" do
            subject { request_get_submissions }
            render_views

            it "should render json" do
              request_get_submissions
              expect(JSON.parse(response.body)).to eq(expected_submissions_rendered_json)
            end

            it "should be successful" do
              expect(response.status).to eq(200) # should be successful
            end
          end
        end
      end

      describe "GET submissions_by_team" do
        it "should set the correct assignment" do
          request_get_submissions_by_team
          expect(assigns(:assignment)).to eq(@assignment)
        end

        it "should set the correct @team" do
          request_get_submissions_by_team
          expect(assigns(:team)).to eq(@team)
        end

        it "should set the expected value for submissions" do
          # add @assignment and @submissions as doubles
          create_doubles_with_ivars("Assignment", "Submissions", "Team")
          stub_assignment_fetcher

          allow(Team).to receive(:find).and_return(@team)
          allow(@assignment).to receive(:student_submissions_for_team).with(@team).and_return(@submissions)

          get :submissions_by_team, { assignment_id: 50, team_id: 900, format: "json"}
          expect(assigns(:submissions)).to eq(@submissions)
        end

        describe "authorizations", working: true do
          context "student makes request" do
            it "should raise a not authorized error" do
            end
          end

          context "staff makes request" do
            it "should be successful" do
            end
          end
        end
      end
    end

    def request_get_submissions
      get :submissions, { assignment_id: @assignment[:id], format: "json" }
    end

    def request_get_submissions_by_team
      get :submissions_by_team, { assignment_id: @assignment[:id], team_id: @team[:id], format: "json"}
    end

    def stub_assignment_fetcher
      allow(Assignment).to receive(:find).and_return(@assignment)
    end

    def expected_submissions_rendered_json
      {
         submissions: AssignmentExportPresenter.new({ submissions: @assignment.student_submissions}).submissions_grouped_by_student
      }
    end
  end
end
