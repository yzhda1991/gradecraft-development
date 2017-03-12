# PageviewEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe ApplicationEventLogger, type: :event_logger, focus: true do
  subject { described_class.new }

  # let(:course) { build_stubbed :course}
  # let(:user) { create(:user) }
  # let(:course_membership)  { create(:course_membership, user: user, course: course) }
  let(:course_membership) do
    double(CourseMembership, course: course, user: user, role: "stuff")
  end
  let(:course) { double(Course, id: 20) }
  let(:user) { double(User, id: 30) }

  it "has a queue" do
    expect(described_class.queue).to eq :application_event_logger
  end

  it "has an accessible :event_session attribute" do
    subject.event_session = "waffles"
    expect(subject.event_session).to eq "waffles"
  end

  it "does not include EventLogger::Enqueue" do
    expect(subject).not_to respond_to(:enqueue_in_with_fallback)
  end

  it "has an #event_type" do
    expect(subject.event_type).to eq "application"
  end

  it "inherits from EventLogger::Base" do
    expect(described_class.superclass).to eq EventLogger::Base
  end

  describe "#event_session_user_role" do
    let(:result) { subject.event_session_user_role }

    context "event session has a user and a course" do
      it "returns the role of the user for the given course" do
        allow(user).to receive(:role).with(course) { course_membership.role }
        subject.event_session = { user: user, course: course }
        expect(result).to eq(course_membership.role)
      end
    end

    context "event session has no user" do
      it "returns nil" do
        subject.event_session = { user: nil, course: "something" }
        expect(result).to be_nil
      end
    end

    context "event session has no course" do
      it "returns nil" do
        subject.event_session = { user: "somebody", course: nil }
        expect(result).to be_nil
      end
    end
  end

  describe "#application_attrs" do
    let(:student) { double(User, id: 90) }
    let(:event_session) do
      { course: course, user: user, student: student }
    end
    let(:base_attrs) { { great: "scott" } }

    before do
      allow(subject).to receive_messages(
        event_session: event_session,
        event_session_user_role: "jester",
        base_attrs: base_attrs
      )
    end

    it "builds a hash of the event_session data from the controller" do
      expect(subject.application_attrs).to eq({
        course_id: course.id,
        user_id: user.id,
        student_id: student.id,
        user_role: "jester",
      }.merge(base_attrs))
    end

    it "is not frozen" do
      expect(subject.application_attrs.frozen?).to be_falsey
    end
  end

  describe "#event_attrs" do
    it "returns the #application_attrs" do
      allow(subject).to receive(:application_attrs) { "some-attrs" }
      expect(subject.event_attrs).to eq "some-attrs"
    end
  end

  describe "#params" do
    it "returns event_sessions[:params]" do
      allow(subject).to receive(:event_session) { { params: "param_stuff" } }
      expect(subject.params).to eq("param_stuff")
    end
  end
end
