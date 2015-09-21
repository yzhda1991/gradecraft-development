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
      describe "GET submissions", working: true do
        it "should set the correct assignment" do
          request_get_submissions
          expect(assigns(:assignment)).to eq(@assignment)
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
            subject { request_get_submissions_by_team }
            render_views

            it "should render json" do
              request_get_submissions_by_team
              expect(JSON.parse(response.body)).to eq(expected_submissions_by_team_rendered_json)
            end

            it "should be successful" do
              expect(response.status).to eq(200) # should be successful
            end
          end
        end
      end

      describe "submissions_by_team_presenter" do
        before(:each) do
          build_controller_instance_with_params(get_submissions_by_team_params)
          trigger_filter_methods :fetch_assignment, :fetch_team
        end

        it "should build an AssignmentExportPresenter" do
          options = {submissions: @assignment.student_submissions_for_team(@team)}
          expect(AssignmentExportPresenter).to receive(:build).with(options)
          @controller.instance_eval { submissions_by_team_presenter }
        end

        it "should assign the presenter instance to @presenter" do
          @controller.instance_eval { submissions_by_team_presenter }
          expect(@controller.instance_eval { @presenter }).to eq(@controller.instance_eval { submissions_by_team_presenter })
        end
      end

      describe "submissions_presenter" do
        before(:each) do
          build_controller_instance_with_params(get_submissions_params)
          trigger_filter_methods :fetch_assignment
        end

        it "should build an AssignmentExportPresenter" do
          options = {submissions: @assignment.student_submissions}
          expect(AssignmentExportPresenter).to receive(:build).with(options)
          @controller.instance_eval { submissions_presenter }
        end

        it "should assign the presenter instance to @presenter" do
          @controller.instance_eval { submissions_presenter }
          expect(@controller.instance_eval { @presenter }).to eq(@controller.instance_eval { submissions_presenter })
        end
      end

      describe "fetch_assignment" do
        it "should return the assignment" do
          build_controller_instance_with_params(get_submissions_params)
          expect(@controller.instance_eval { fetch_assignment }).to eq(@assignment)
        end
      end

      describe "fetch_team" do
        it "should return the team" do
          build_controller_instance_with_params(get_submissions_by_team_params)
          expect(@controller.instance_eval { fetch_team }).to eq(@team)
        end
      end
    end
  end

  def build_controller_instance_with_params(params)
    @controller = AssignmentExportsController.new
    allow(@controller).to receive(:params).and_return(params)
  end

  def trigger_filter_methods(*filter_methods)
    filter_methods.each do |filter_method|
      @controller.instance_eval {  send(filter_method) }
    end
  end

  def request_get_submissions
    get :submissions, get_submissions_params
  end

  def get_submissions_params
    { assignment_id: @assignment[:id], format: "json" }
  end

  def request_get_submissions_by_team
    get :submissions_by_team, get_submissions_by_team_params
  end

  def get_submissions_by_team_params
    { assignment_id: @assignment[:id], team_id: @team[:id], format: "json"}
  end

  def stub_assignment_fetcher
    allow(Assignment).to receive(:find).and_return(@assignment)
  end

  def temp_view_context
    @temp_view_context ||= ApplicationController.new.view_context
  end

  def expected_submissions_rendered_json
    JbuilderTemplate.new(temp_view_context).encode do |json|
      json.partial! "assignment_exports/submissions", presenter: submissions_presenter_instance
    end
  end

  def expected_submissions_by_team_rendered_json
    JbuilderTemplate.new(temp_view_context).encode do |json|
      json.partial! "assignment_exports/submissions_by_team", presenter: submissions_by_team_presenter_instance
    end
  end

  def submissions_by_team_presenter_instance
    AssignmentExportPresenter.new({ submissions: @assignment.student_submissions_for_team(@team)})
  end

  def submissions_presenter_instance
    AssignmentExportPresenter.new({ submissions: @assignment.student_submissions})
  end
end
