require "rails_spec_helper"

include GoogleCalendarsHelper

describe GoogleCalendarsHelper do

  describe "#get_google_authorization" do
    let(:user) { create :user }
    it "refreshes the google authorization if the token has expired" do
      create :user_authorization, :google, user: user, access_token: "BLEH", refresh_token: "REFRESH", expires_at: Time.now - (60 * 60)
      expect(helper).to receive(:refresh_if_google_authorization_is_expired)
      helper.get_google_authorization(user)
    end
  end

  describe "#get_item" do
    let(:user) { create :user }
    let(:course) { build(:course) }
    let(:event) {create(:event, course: course)}
    let(:assignment_type) { create(:assignment_type, course: course) }
    let(:assignment) { create(:assignment, assignment_type: assignment_type, course: course) }
    it "returns the event of the corresponding event object" do
      expect(get_item(course, "event", event.id).id).to be event.id
      expect(get_item(course, "event", event.id).class).to be Event
    end

    it "returns the assignment of the corresponding event object" do
      expect(get_item(course, "assignment", assignment.id).id).to be assignment.id
      expect(get_item(course, "assignment", assignment.id).class).to be Assignment
    end
  end

  describe "#get_all_items" do
    let(:user) { create :user }
    let(:course) { build(:course) }
    let(:professor) { create(:course_membership, :professor, course: course).user }
    let(:event) {create(:event, course: course)}
    let(:event2) {create(:event, course: course)}
    let(:event3) {create(:event, course: course)}
    let(:assignment_type) { create(:assignment_type, course: course) }
    let(:assignment) { create(:assignment, assignment_type: assignment_type, course: course) }
    let(:assignment2) { create(:assignment, assignment_type: assignment_type, course: course) }
    let(:assignment3) { create(:assignment, assignment_type: assignment_type, course: course) }
    it "returns returns array of events or assignments" do
      expect(get_all_items_for_current_course(course, "event", user)).to be course.events
      expect(get_all_items_for_current_course(course, "assignment", professor)).to be course.assignments
    end
  end

  describe "#retrieve_visible_assignments" do

  end

  describe "#filter_items_with_no_end_date" do

  end

  describe "#add_multiple_items" do

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
    let(:assignment_type) { create(:assignment_type, course: course) }
    let(:assignment) { create(:assignment, assignment_type: assignment_type, course: course) }
    it "creates a google calendar event object from a GradeCraft event" do
      event.open_at = Time.now - (24 * 60 * 60)
      google_event = create_google_event(event)
      expect(google_event).not_to be nil
      expect(event.name).to be google_event.summary
      expect(event.open_at.to_datetime.rfc3339).to eq google_event.start[:date_time]
      expect(event.due_at.to_datetime.rfc3339).to eq google_event.end[:date_time]
    end

    it "creates a google calendar event object from a GradeCraft assignment" do
      assignment.due_at = Time.now - (24 * 60 * 60)
      google_event = create_google_event(assignment)
      expect(google_event).not_to be nil
      expect(assignment.name).to be google_event.summary
      expect((assignment.due_at - 30.minutes).to_datetime.rfc3339).to eq google_event.start[:date_time]
      expect(assignment.due_at.to_datetime.rfc3339).to eq google_event.end[:date_time]
    end
  end

end
