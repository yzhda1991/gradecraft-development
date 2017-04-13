require "rails_spec_helper"

  include GoogleCalendarHelper

describe GoogleCalendarHelper, focus: true do

  describe "#get_google_authorization" do
    let(:user) { create :user }
    it "refreshes the google authorization if the token has expired" do
      create :user_authorization, :google, user: user, access_token: "BLEH", refresh_token: "REFRESH", expires_at: Time.now - (60 * 60)
      expect(helper).to receive(:refresh_if_google_authorization_is_expired)
      helper.get_google_authorization(user)
    end
  end

  describe "#refresh_if_google_authorization_is_expired" do
    let(:user) { create :user }
    let(:google_auth) { create :user_authorization, :google, user: user, access_token: "BLEH", refresh_token: "REFRESH", expires_at: Time.now - (60 * 60) }
    it "calls #refresh! on authorization if the token has expired" do
      expect(google_auth).to receive(:refresh!)
      helper.refresh_if_google_authorization_is_expired(google_auth)
    end
  end

  describe "#google_auth_present?" do
    let(:user) {create :user}
    it "returns false if a user_authorization with provider google_oauth2 is not found" do
      expect(google_auth_present?(user)).to be false
    end

    it "returns true if a user_authorization with provider google_oauth2 is found" do
      create :user_authorization, :google, user: user
      expect(google_auth_present?(user)).to be true
    end
  end

  describe "#create_google_event" do
    let(:course) { build(:course) }
    let(:event) { create(:event, course: course) }
    it "creates a google calendar event object" do
      event.open_at = Time.now - (24 * 60 * 60)
      google_event = create_google_event(event)
      expect(google_event).not_to be nil
      expect(event.name).to be google_event.summary
      expect(event.open_at.to_datetime.rfc3339).to eq google_event.start[:date_time]
      expect(event.due_at.to_datetime.rfc3339).to eq google_event.end[:date_time]
    end
  end

end
