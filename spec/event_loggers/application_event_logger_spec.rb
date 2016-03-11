require "active_record_spec_helper"
require "resque_spec/scheduler"

# PageviewEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe ApplicationEventLogger, type: :event_logger do

  subject { described_class.new }
  let(:new_logger) { ApplicationEventLogger.new }


  describe "#params" do
    it "returns event_sessions[:params]" do
      allow(subject).to receive(:event_session) { { params: "param_stuff" } }
      expect(subject.params).to eq("param_stuff")
    end
  end

  describe "#event_session_user_role" do
    let(:result) { subject.event_session_user_role(event_session) }

    before(:each) do
      allow(subject).to receive(:event_session) { event_session }
    end

    context "event session has a user" do
      let(:course_membership) { create :student_course_membership }
      let(:event_session) do
        { user: course_membership.user, course: course_membership.course }
      end

      it "returns the role of the user for the given course" do
        expect(result).to eq(course_membership.role)
      end
    end

    context "event session has no user" do
      let(:event_session) { Hash.new }
      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end

  describe "#application_attrs" do
    it "builds a hash of the event_session data from the controller" do
    end
  end

  describe "#event_attrs" do
    it "should be the same as the #application_attrs" do
    end
  end
end
