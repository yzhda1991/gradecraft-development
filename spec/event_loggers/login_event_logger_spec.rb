require 'rails_spec_helper'

include Toolkits::EventLoggers::SharedExamples

# LoginEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe LoginEventLogger, type: :background_job do
  include InQueueHelper # get help from ResqueSpec

  let(:new_logger) { LoginEventLogger.new(logger_attrs) }
  let(:course) { build(:course) }
  let(:user) { build(:user) }

  let(:logger_attrs) {{
    course_id: course.id,
    user_id: user.id,
    student_id: 90,
    user_role: "great role",
    page: "/a/great/path",
    created_at: Time.parse("Jan 20 1972")
  }}

  # shared examples for EventLogger subclasses
  it_behaves_like "an EventLogger subclass", LoginEventLogger, "login"
  it_behaves_like "EventLogger::Enqueue is included", LoginEventLogger, "login"

  describe "class methods" do
    describe "self#peform" do
      subject { class_instance.perform('login', logger_attrs) }

      let(:course_membership) { create(:professor_course_membership, course: course, user: user, last_login_at: last_login) }
      let(:last_login) { Time.parse("June 20, 1968") }
      let(:class_instance) { LoginEventLogger }

      before(:each) { course_membership }

      it "merges the previous last_login_at value into the data hash" do
        allow(class_instance).to receive(:previous_last_login_at) { last_login.to_i }
        expect(logger_attrs).to receive(:merge!).with({ last_login_at: last_login.to_i })
        subject
      end

      it "sets the data hash to @data" do
        subject
        expect(class_instance.instance_variable_get(:@data)).to eq(logger_attrs)
      end

      it "calls self#perform from the superclass" do
      end

      it "updates the last login" do
      end
    end
  end
end
