require "active_record_spec_helper"
require "resque_spec/scheduler"

require_relative "../toolkits/event_loggers/shared_examples"
require_relative "../toolkits/event_loggers/attributes"
require_relative "../toolkits/event_loggers/event_session"
require_relative "../toolkits/event_loggers/application_event_logger_toolkit"

# LoginEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe LoginEventLogger, type: :event_logger do
  include InQueueHelper # get help from ResqueSpec
  include Toolkits::EventLoggers::SharedExamples
  include Toolkits::EventLoggers::Attributes
  include Toolkits::EventLoggers::ApplicationEventLoggerToolkit
  extend Toolkits::EventLoggers::EventSession

  subject { LoginEventLogger }

  # build this off of the class instance for consistent behavior
  let(:new_logger) { described_class.new(event_session) }

  let!(:course_membership) { create(:professor_course_membership, course: course, user: user, last_login_at: last_login) }
  let(:last_login) { Time.parse("June 20, 1968") }

  # pulls in #event_session attributes from EventLoggers::EventSession
  # creates course, user, student objects, and a request double
  define_event_session_with_request

  let(:logger_attrs) { login_logger_attrs } # pulled in from Toolkits::EventLoggers::Attributes
  let(:expected_base_attrs) { application_logger_base_attrs } # pulled in from Toolkits::EventLoggers::ApplicationEventLoggerToolkit

  # shared examples for EventLogger subclasses
  it_behaves_like "an EventLogger subclass", LoginEventLogger, "login"
  it_behaves_like "EventLogger::Enqueue is included", LoginEventLogger, "login"

  describe "class methods" do
    describe ".perform" do
      let(:result) { subject.perform('login', logger_attrs) }

      before(:each) { course_membership }

      it "merges the previous last_login_at value into the data hash" do
        allow(subject).to receive(:previous_last_login_at) { last_login.to_i }
        expect(logger_attrs).to receive("[]=").with(:last_login_at, last_login.to_i)
        result
      end

      it "sets the data hash to @cached_data" do
        result
        expect(subject.instance_variable_get(:@cached_data)).to eq(logger_attrs)
      end

      it "calls .perform from the superclass" do
        expect(subject.logger).to receive(:info).exactly(3).times
        result
      end

      context "a course membership is present" do
        it "updates the last login" do
          expect(subject).to receive(:update_last_login)
          result
        end
      end

      context "no course membership is present" do
        it "updates the last login" do
          allow(subject).to receive(:course_membership_present?) { nil }
          expect(subject).not_to receive(:update_last_login)
          result
        end
      end
    end

    describe ".update_last_login" do
      let(:time_zone_now) { Date.parse("April 9 1992").to_time }
      let(:data) {{ created_at: time_zone_now }}

      before do
        subject.instance_variable_set(:@cached_data, data)
        allow(subject).to receive(:course_membership) { course_membership }
      end

      it "updates the last_login_at for the course membership" do
        expect(course_membership).to receive(:update_attributes).with({ last_login_at: time_zone_now })
        subject.update_last_login
      end
    end

    describe ".course_membership" do
      let(:result) { subject.course_membership }

      before(:each) do
        course_membership # cache the course membership
        subject.instance_variable_set(:@course_membership, nil)
        allow(subject).to receive(:course_membership_attrs) {{ course_id: course.id, user_id: user.id }}
      end

      it "returns the correct course membership" do
        expect(result).to eq(course_membership)
      end

      it "caches the course membership" do
        result
        expect(CourseMembership).not_to receive(:where)
        result
      end

      it "sets the course membership to @course_membership" do
        result
        expect(subject.instance_variable_get(:@course_membership))
          .to eq(course_membership)
      end
    end

    describe ".course_membership_attrs" do
      let(:result) { subject.course_membership_attrs }
      let(:data) { { course_id: 20, user_id: 90 } }

      before do
        subject.instance_variable_set(:@cached_data, data)
      end

      it "returns the timestamp as an integer in seconds" do
        expect(result).to eq(data)
      end
    end

    describe ".course_membership_present?" do
      let(:result) { subject.course_membership_present? }

      before(:each) do
        allow(subject).to receive_messages(
          course_membership: true,
          course_membership_attrs_present?: true
        )
      end

      context "course membership attrs exist but the resource is not found" do
        it "returns true" do
          expect(result).to be_truthy
        end
      end

      context "course membership attributes are not present" do
        it "returns false" do
          allow(subject).to receive(:course_membership_attrs_present?)
            .and_return false
          expect(result).to be_falsey
        end
      end

      context "course membership resource does not exist" do
        it "returns false" do
          allow(subject).to receive(:course_membership) { false }
          expect(result).to be_falsey
        end
      end
    end

    describe ".course_membership_attrs_present?" do
      let(:result) { subject.course_membership_attrs_present? }

      before(:each) do
        subject.instance_variable_set(:@cached_data, cached_data)
      end

      context "course_id and user_id are present in the @cached_data" do
        let(:cached_data) { { course_id: 5, user_id: 6 } }
        it "returns true" do
          expect(result).to be_truthy
        end
      end

      context "course_id is not present" do
        let(:cached_data) { { course_id: nil, user_id: 6 } }
        it "returns false" do
          expect(result).to be_falsey
        end
      end

      context "user_id is not present" do
        let(:cached_data) { { course_id: 20, user_id: nil } }
        it "returns false" do
          expect(result).to be_falsey
        end
      end
    end

    describe ".previous_last_login_at" do
      let(:result) { subject.previous_last_login_at }

      context "a course membership is present" do
        before do
          allow(subject).to receive_messages(
            course_membership: course_membership,
            course_membership_present?: true
          )
        end

        context "course membership has a last_login_at value" do
          it "returns the timestamp as an integer in seconds" do
            allow(course_membership).to receive(:last_login_at) { last_login }
            expect(result).to eq(last_login.to_i)
          end
        end

        context "course membership has no last_login_at value" do
          it "returns nil" do
            allow(course_membership).to receive(:last_login_at) { nil }
            expect(result).to be_nil
          end
        end
      end

      context "no course membership is found for the login data" do
        before do
          allow(subject).to receive(:course_membership_present?) { nil }
        end

        it "returns nil" do
          allow(course_membership).to receive(:last_login_at) { nil }
          expect(result).to be_nil
        end
      end
    end
  end
end
