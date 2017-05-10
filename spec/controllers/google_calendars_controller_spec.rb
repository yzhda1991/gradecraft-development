require "rails_spec_helper"
require "api_spec_helper"

describe GoogleCalendarsController, type:[:disable_external_api, :controller] do
  let(:provider) { :google_oauth2 }
  let(:course) { build :course }
  let(:event) { create :event, course: course, open_at: DateTime.new(2017,4,1,16,0,0,-4), due_at: DateTime.new(2017,4,1,17,0,0,-4), name: "animi" }
  let(:standard_event) { create :event, course: course, open_at: Time.now - (24 * 60 * 60), due_at: Time.now}
  let(:no_start_event) { create :event, course: course, open_at: nil, due_at: Time.now}
  let(:no_end_event) { create :event, course: course, open_at: Time.now - (24 * 60 * 60), due_at: nil}
  let(:no_name_event) { create :event, course: course, open_at: Time.now - (24 * 60 * 60), due_at: Time.now, name: nil}
  let(:assignment_type) { create(:assignment_type, course: course) }
  let(:assignment) { create(:assignment, assignment_type: assignment_type, course: course, due_at: DateTime.new(2017,4,1,17,0,0,-4)) }
  let(:no_start_assignment) { create(:assignment, assignment_type: assignment_type, course: course, open_at: nil, due_at: DateTime.new(2017,4,1,17,0,0,-4)) }
  let(:no_end_assignment) { create(:assignment, assignment_type: assignment_type, course: course, open_at: nil, due_at: nil) }
  let(:student) { build :user, courses: [course], role: :student }

  before do
    stub_request(:post, "https://accounts.google.com/o/oauth2/token").
      with(:body => {"client_id"=>"GOOGLE_CLIENT_ID", "client_secret"=>"GOOGLE_SECRET", "grant_type"=>""}).
      to_return(:status => 200, :body => "", :headers => {'Content-Type'=>'application/x-www-form-urlencoded'})

    stub_const('ENV', ENV.to_hash.merge('GOOGLE_CLIENT_ID' => 'GOOGLE_CLIENT_ID'))
    stub_const('ENV', ENV.to_hash.merge('GOOGLE_SECRET' => 'GOOGLE_SECRET'))
  end

  before(:each) { login_user(student) }

  describe "POST add_to_google_calendar" do
    before(:each) do
      stub_request(:post, "https://www.googleapis.com/calendar/v3/calendars/primary/events").
        to_return(:status => 200, :body => "", :headers => {})
    end

    # Authorized User attempting add standard event
    context "with an existing authentication" do
      let! (:user_auth) { create :user_authorization, :google, user: student, access_token: "token", expires_at: 2.days.from_now}

      it "redirects to events path with a successful notice when attempting to add a standard event" do
        post :add_to_google_calendar, params: { class: "event", id: standard_event.id }

        expect(response).to redirect_to events_path
        expect(flash[:notice]).to eq("Event " + standard_event.name + " successfully added to your Google Calendar")
      end

      # Authorized User attempting to add an event with no end date
      it "redirects to events path with an alert notice when attempting to add an event with no due date" do
        post :add_to_google_calendar, params: { class: "event", id: no_end_event.id }

        expect(response).to redirect_to events_path
        expect(flash[:alert]).to eq("Google Calendar requires event have at least END time!")
      end

      # Authorized User attempting to add a standard event without Google Client Id and Secret
      it "redirects to events path with an unsuccessful alert when user doesn't have proper Google Client Id and/or Secret" do

        stub_request(:post, "https://accounts.google.com/o/oauth2/token").
          with(:body => {"client_id"=>"WRONG_VALUE", "client_secret"=>"WRONG_VALUE", "grant_type"=>""}).
          to_return(:status => 401, :body => "", :headers => {'Content-Type'=>'application/x-www-form-urlencoded'})

        stub_const('ENV', ENV.to_hash.merge('GOOGLE_CLIENT_ID' => 'WRONG_VALUE'))
        stub_const('ENV', ENV.to_hash.merge('GOOGLE_SECRET' => 'WRONG_VALUE'))

        post :add_to_google_calendar, params: { class: "event", id: standard_event.id }

        expect(response).to redirect_to events_path
        expect(flash[:alert]).to eq("Google Calendar encountered an Error. Your event was NOT copied to your Google calendar.")
      end
    end

    # Unauthorized User attempting to add a standard event with no end date
    context "without an existing authentication" do
      it "redirects to google authentication page" do

        post :add_to_google_calendar, params: { class: "event", id: no_end_event.id }

        expect(response).to redirect_to "/auth/google_oauth2"
      end
    end
  end

  describe "POST add_to_google_calendar" do
    before(:each) do
      stub_request(:post, "https://www.googleapis.com/calendar/v3/calendars/primary/events").
        to_return(:status => 200, :body => "", :headers => {})
    end

    # Authorized User attempting add standard assignment
    context "with an existing authentication" do
      let! (:user_auth) { create :user_authorization, :google, user: student, access_token: "token", expires_at: 2.days.from_now}

      it "redirects to assignments path with a successful notice when attempting to add a standard assignment" do
        post :add_to_google_calendar, params: { class: "assignment", id: assignment.id }

        expect(response).to redirect_to assignments_path
        expect(flash[:notice]).to eq("Assignment " + assignment.name + " successfully added to your Google Calendar")
      end

      # Authorized User attempting to add an assignment with no start date
      it "redirects to assignments path with a successful notice when attempting to add an assignment with no open date, generates open date to be 30 minutes prior to due date" do
        post :add_to_google_calendar, params: { class: "assignment", id: no_start_assignment.id}

        expect(response).to redirect_to assignments_path
        expect(flash[:notice]).to eq("Assignment " + no_start_assignment.name + " successfully added to your Google Calendar")
      end

      # Authorized User attempting to add an assignment with no start and no end date
      it "redirects to assignments path with an alert notice when attempting to add an event with no due date" do
        post :add_to_google_calendar, params: { class: "assignment", id: no_end_assignment.id}

        expect(response).to redirect_to assignments_path
        expect(flash[:alert]).to eq("Google Calendar requires assignment have at least END time!")
      end

      # Authorized User attempting to add a standard assignment without Google Client Id and Secret
      it "redirects to assignments path with an unsuccessful alert when user doesn't have proper Google Client Id and/or Secret" do

        stub_request(:post, "https://accounts.google.com/o/oauth2/token").
          with(:body => {"client_id"=>"WRONG_VALUE", "client_secret"=>"WRONG_VALUE", "grant_type"=>""}).
          to_return(:status => 401, :body => "", :headers => {'Content-Type'=>'application/x-www-form-urlencoded'})

        stub_const('ENV', ENV.to_hash.merge('GOOGLE_CLIENT_ID' => 'WRONG_VALUE'))
        stub_const('ENV', ENV.to_hash.merge('GOOGLE_SECRET' => 'WRONG_VALUE'))

        post :add_to_google_calendar, params: { class: "assignment", id: assignment.id}

        expect(response).to redirect_to assignments_path
        expect(flash[:alert]).to eq("Google Calendar encountered an Error. Your assignment was NOT copied to your Google calendar.")
      end
    end

    # Unauthorized User attempting to add a standard assignment with no end date
    context "without an existing authentication" do
      it "redirects to google authentication page" do

        post :add_to_google_calendar, params: { class: "assignment", id: no_end_event.id}

        expect(response).to redirect_to "/auth/google_oauth2"
      end
    end
  end
end
