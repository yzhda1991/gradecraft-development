require "rails_spec_helper"

describe GoogleCalendarController do
  let(:provider) { :google_oauth2 }

  context "as a user" do
    let(:course) { create :course }
    let(:event) { create :event, course: course }
    let(:student_membership) { create :course_membership, :student, course: course }
    let(:student) { student_membership.user }

    before { login_user(student) }

    describe "GET add_event_to_google_calendar", focus: true do
      # Unauthorized user attempting add event
      context "without an existing authentication" do
        it "redirects to authorize the Google integration" do
          post :create, params: { integration_id: provider }

          expect(response).to redirect_to "/auth/google_oauth2"
        end
      end

      # User with an existing authentication attempting to add an event
      context "with an existing authentication" do
        let(:user_authorization) { create :user_authorization, :google, user: student }

        it "should not fetch new google authentication token" do
          expect(get :add_event_to_google_calendar, params: { id: event.id }).to_not redirect_to "/auth/google_oauth2"
        end
      end

      # Authorized user attempting to add valid event
      context "with an existing event including start and end date" do
        let(:user_authorization) { create :user_authorization, :google, user: student }

        it "should not fetch new google authentication token" do
          expect(get :add_event_to_google_calendar, params: { id: event.id }).to_not redirect_to "/auth/google_oauth2"
        end
      end

      # Authorized user attempting to add event without end date
      context "with an existing event including only start date" do
        let(:user_authorization) { create :user_authorization, :google, user: student }

        it "should not fetch new google authentication token" do
          expect(get :add_event_to_google_calendar, params: { id: event.id }).to_not redirect_to "/auth/google_oauth2"
        end
      end

      # Authorized user attempting to add event without start date
      context "with an existing event including only end date" do
        let(:user_authorization) { create :user_authorization, :google, user: student }

        it "should not fetch new google authentication token" do
          expect(get :add_event_to_google_calendar, params: { id: event.id }).to_not redirect_to "/auth/google_oauth2"
        end
      end

      # context "with an expired authentication" do
      #   let!(:user_authorization) do
      #     create :user_authorization, :canvas, user: professor,
      #       access_token: "BLAH", expires_at: 2.days.ago
      #   end
      #
      #   it "retrieves a refresh token" do
      #     expect_any_instance_of(UserAuthorization).to receive(:refresh!)
      #
      #     post :create, params: { integration_id: provider }
      #   end
      # end
      #
      # context "with an existing authentication" do
      #   let!(:user_authorization) do
      #     create :user_authorization, :canvas, user: professor,
      #       access_token: "BLAH", expires_at: 2.days.from_now
      #   end
      #
      #   it "redirects to the redirect url" do
      #     post :create, params: { integration_id: provider }
      #
      #     expect(response).to redirect_to integration_courses_path(:canvas)
      #   end
      # end
    end
  end

  # context "as a student" do
  #   let(:student) { student_membership.user }
  #   let(:student_membership) { create :course_membership, :student }
  #
  #   before { login_user(student) }
  #
  #   it "redirects to the root" do
  #     post :create, params: { integration_id: provider }
  #
  #     expect(response).to redirect_to root_path
  #   end
  end
end
