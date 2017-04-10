require "rails_spec_helper"
require "api_spec_helper"

describe GoogleCalendarController, type:[:disable_external_api, :controller] do
  let(:provider) { :google_oauth2 }

  before do
    stub_request(:post, "https://accounts.google.com/o/oauth2/token").
      with(:body => {"client_id"=>"GOOGLE_CLIENT_ID", "client_secret"=>"GOOGLE_SECRET", "grant_type"=>""}).
      to_return(:status => 200, :body => "", :headers => {'Content-Type'=>'application/x-www-form-urlencoded'})

    stub_request(:post, "https://accounts.google.com/o/oauth2/token").
      with(:body => {"client_id"=>"WRONG_VALUE", "client_secret"=>"WRONG_VALUE", "grant_type"=>""}).
      to_return(:status => 401, :body => "", :headers => {'Content-Type'=>'application/x-www-form-urlencoded'})

    stub_request(:post, "https://www.googleapis.com/calendar/v3/calendars/primary/events").
      to_return(:status => 200, :body => "", :headers => {})
  end

  context "as a user" do
    let(:course) { create :course }
    let(:event) { create :event, course: course, open_at: DateTime.new(2017,4,1,16,0,0,-4), due_at: DateTime.new(2017,4,1,17,0,0,-4), name: "animi" }
    let(:standard_event) { create :event, course: course, open_at: Time.now - (24 * 60 * 60), due_at: Time.now}
    let(:no_start_event) { create :event, course: course, open_at: nil, due_at: Time.now}
    let(:no_end_event) { create :event, course: course, open_at: Time.now - (24 * 60 * 60), due_at: nil}
    let(:no_name_event) { create :event, course: course, open_at: Time.now - (24 * 60 * 60), due_at: Time.now, name: nil}
    let(:student_membership) { create :course_membership, :student, course: course }
    let(:student) { student_membership.user }

    before(:each) { login_user(student) }

    describe "POST add_event_to_google_calendar" do
      # Authorized User attempting add standard event
      context "with an existing authentication" do
        let! (:user_auth) { create :user_authorization, :google, user: student, access_token: "token", expires_at: 2.days.from_now}
        describe "and a standard event" do
          it "redirects to events path with a successful notice" do

            stub_const('ENV', ENV.to_hash.merge('GOOGLE_CLIENT_ID' => 'GOOGLE_CLIENT_ID'))
            stub_const('ENV', ENV.to_hash.merge('GOOGLE_SECRET' => 'GOOGLE_SECRET'))

            post :add_event_to_google_calendar, params: { id: standard_event.id}

            expect(response).to redirect_to events_path
            expect(flash[:notice]).to eq("Event " + standard_event.name + " successfully added to your Google Calendar")
          end
        end

        # Authorized User attempting to add an event with no start date
        describe "and an event with no open date" do
          it "redirects to events path with an alert notice" do

            stub_const('ENV', ENV.to_hash.merge('GOOGLE_CLIENT_ID' => 'GOOGLE_CLIENT_ID'))
            stub_const('ENV', ENV.to_hash.merge('GOOGLE_SECRET' => 'GOOGLE_SECRET'))

            post :add_event_to_google_calendar, params: { id: no_start_event.id}

            expect(response).to redirect_to events_path
            expect(flash[:alert]).to eq("Google Calendar requires event have both START and END time!")
          end
        end

        # Authorized User attempting to add an event with no end date
        describe "and an event with no due date" do
          it "redirects to events path with an alert notice" do

            stub_const('ENV', ENV.to_hash.merge('GOOGLE_CLIENT_ID' => 'GOOGLE_CLIENT_ID'))
            stub_const('ENV', ENV.to_hash.merge('GOOGLE_SECRET' => 'GOOGLE_SECRET'))

            post :add_event_to_google_calendar, params: { id: no_end_event.id}

            expect(response).to redirect_to events_path
            expect(flash[:alert]).to eq("Google Calendar requires event have both START and END time!")
          end
        end

        # Authorized User attempting to add a standard event without Google Client Id and Secret
        describe "without Google Client Id and Secret" do
          it "redirects to events path with an unsuccessful alert" do

            stub_const('ENV', ENV.to_hash.merge('GOOGLE_CLIENT_ID' => 'WRONG_VALUE'))
            stub_const('ENV', ENV.to_hash.merge('GOOGLE_SECRET' => 'WRONG_VALUE'))

            post :add_event_to_google_calendar, params: { id: standard_event.id}

            expect(response).to redirect_to events_path
            expect(flash[:alert]).to eq("Google Calendar encountered an Error. Your event was NOT copied to your Google calendar.")
          end
        end
      end

      # Unauthorized User attempting to add a standard event with no end date
      context "without an existing authentication" do
        let(:student) { student_membership.user }
        let(:student_membership) { create :course_membership, :student, course: course }
        it "redirects to google authentication page" do

          stub_const('ENV', ENV.to_hash.merge('GOOGLE_CLIENT_ID' => 'GOOGLE_CLIENT_ID'))
          stub_const('ENV', ENV.to_hash.merge('GOOGLE_SECRET' => 'GOOGLE_SECRET'))

          post :add_event_to_google_calendar, params: { id: no_end_event.id}

          expect(response).to redirect_to "/auth/google_oauth2"
        end
      end

    end
  end
end
