require 'rails_spec_helper'
require_relative '../support/uni_mock/stub_time'


# LoginEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe LoginEventLogger, type: :background_job do
  include InQueueHelper # get help from ResqueSpec
  include Toolkits::EventLoggers::SharedExamples
  include Toolkits::EventLoggers::Attributes
  extend Toolkits::EventLoggers::EventSession

  # this needs to be declared since Resque interacts with class-level instance
  # variables, and using mulitple class instances could misrepresent class-level
  # instance variable circumstances
  let(:class_instance) { LoginEventLogger }

  # build this off of the class instance for consistent behavior
  let(:new_logger) { class_instance.new(event_session) }

  let!(:course_membership) { create(:professor_course_membership, course: course, user: user, last_login_at: last_login) }
  let!(:course) { create(:course) }
  let!(:user) { create(:user) }
  let(:last_login) { Time.parse("June 20, 1968") }

  define_event_session # pulls in #event_session attributes from EventLoggers::EventSession

  let(:logger_attrs) { login_logger_attrs } # pulled in from Toolkits::EventLoggers::Attributes

  # shared examples for EventLogger subclasses
  it_behaves_like "an EventLogger subclass", LoginEventLogger, "login"
  it_behaves_like "EventLogger::Enqueue is included", LoginEventLogger, "login"

  describe "class methods" do
    describe "self#peform" do
      subject { class_instance.perform('login', logger_attrs) }

      before(:each) { course_membership }

      it "sets the data hash to @data" do
        subject
        expect(class_instance.instance_variable_get(:@data)).to eq(logger_attrs)
      end

      it "calls self#perform from the superclass" do
        expect(class_instance.logger).to receive(:info).exactly(2).times
        subject
      end

      it "updates the last login" do
        expect(class_instance).to receive(:update_last_login)
        subject
      end
    end

    describe "self#update_last_login" do
      let(:time_zone_now) { Date.parse("April 9 1992").to_time }
      let(:data) {{ created_at: time_zone_now }}

      before do
        class_instance.instance_variable_set(:@data, data)
        allow(class_instance).to receive(:course_membership) { course_membership }
      end

      it "updates the last_login_at for the course membership" do
        expect(course_membership).to receive(:update_attributes).with({ last_login_at: time_zone_now })
        class_instance.update_last_login
      end
    end

    describe "self#course_membership" do
      subject { class_instance.course_membership }

      let(:course) { create(:course) }
      let(:user) { create(:user) }

      before(:each) do
        course_membership # cache the course membership
        class_instance.instance_variable_set(:@course_membership, nil)
        allow(class_instance).to receive(:course_membership_attrs) {{ course_id: course.id, user_id: user.id }}
      end

      it "returns the correct course membership" do
        expect(subject).to eq(course_membership)
      end
    end

    describe "self#course_membership_attrs" do
      subject { class_instance.course_membership_attrs }
      let(:data) {{ course_id: 20, user_id: 90 }}

      before do
        class_instance.instance_variable_set(:@data, data)
      end

      it "returns the timestamp as an integer in seconds" do
        expect(subject).to eq(data)
      end
    end

    describe "previous_last_login_at" do
      subject { new_logger.previous_last_login_at }

      before do
        allow(new_logger).to receive(:course_membership) { course_membership }
      end

      context "course membership has a last_login_at value" do
        it "returns the timestamp as an integer in seconds" do
          allow(course_membership).to receive(:last_login_at) { last_login }
          expect(subject).to eq(last_login.to_i)
        end
      end

      context "course membership has no last_login_at value" do
        it "returns nil" do
          allow(course_membership).to receive(:last_login_at) { nil }
          expect(subject).to be_nil
        end
      end
    end

    describe "#event_attrs" do
      subject { new_logger.event_attrs }
      let(:previous_last_login_at) { (Time.zone.now - 5.days).to_i }

      before do
        allow(new_logger).to receive(:previous_last_login_at) { previous_last_login_at }
      end

      it "merges the page from the original request with the base_attrs" do
        expect(subject).to eq new_logger.base_attrs.merge(last_login_at: previous_last_login_at)
      end

      it "caches the #event_attrs" do
        subject
        expect(new_logger.base_attrs).not_to receive(:merge)
        subject
      end

      it "sets the event attrs to @event_attrs" do
        subject
        expect(new_logger.instance_variable_get(:@event_attrs)).to eq(new_logger.event_attrs)
      end
    end

    describe "#course_membership" do
      subject { new_logger.course_membership }

      before do
        new_logger.instance_variable_set(:@course_membership, nil)
        course_membership # cache the course membership
        allow(new_logger).to receive(:course_membership_attrs) {{ course_id: course.id, user_id: user.id }}
      end

      it "returns the correct course membership" do
        expect(subject).to eq(course_membership)
      end

      it "caches the course membership" do
        subject
        expect(CourseMembership).not_to receive(:where)
        subject
      end

      it "sets the course membership to @course_membership" do
        subject
        expect(new_logger.instance_variable_get(:@course_membership)).to eq(course_membership)
      end
    end

  end
end
