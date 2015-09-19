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
          get_submissions
          expect(Assignment).to receive(:find).with(@assignment[:id].to_s).and_return (@assignment)
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
          get_submissions
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

        describe "authorizations", working: true do
          before(:each) do
            clear_rails_cache
            setup_submissions_environment_with_users
          end

          context "student makes request" do
            it "should redirect to the homepage" do
              logout_user # logout professor
              login_user(@student1) # login student
              get_submissions
              expect(response).to redirect_to(root_url)
            end
          end

          context "staff makes request" do
            render_views
            let(:json) { JSON.parse(response.body) }
            subject { get_submissions }

            it "should render json" do
              expect(@json).to eq({})
            end

            it "should be successful" do
              expect(response.status).to eq(200) # should be successful
            end
          end
        end
      end

      describe "GET submissions_by_team" do
        it "should set the correct assignment" do
          get_submissions_by_team
          expect(assigns(:assignment)).to eq(@assignment)
        end

        it "should set the correct @team" do
          get_submissions_by_team
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

    def get_submissions
      get :submissions, { assignment_id: @assignment[:id], format: "json" }
    end

    def get_submissions_by_team
      get :submissions_by_team, { assignment_id: @assignment[:id], team_id: @team[:id], format: "json"}
    end

    def stub_assignment_fetcher
      allow(Assignment).to receive(:find).and_return(@assignment)
    end
  end
end
