require 'rails_spec_helper'

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

  describe "class-level instance variables" do
    describe "@queue" do
      it "uses the login_event_logger queue" do
        expect(LoginEventLogger.instance_variable_get(:@queue)).to eq(:login_event_logger)
      end
    end

    describe "@event_name" do
      it "uses Login as an event name for messaging" do
        expect(LoginEventLogger.instance_variable_get(:@event_name)).to eq("Login")
      end
    end
  end

  describe "#event_type" do
    it "provides 'login' as an event type" do
      expect(new_logger.event_type).to eq("login")
    end
  end

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

  describe "#initialize" do
    subject { new_logger }

    it "should set an @attrs hash" do
      expect(subject.instance_variable_get(:@attrs)).to eq(logger_attrs)
    end
  end

  describe "enqueuing" do
    before(:each) do
      ResqueSpec.reset!
    end

    describe "enqueue without schedule" do
      before(:each) { new_logger.enqueue }

      it "should find a job in the login queue" do
        resque_job = Resque.peek(:login_event_logger)
        expect(resque_job).to be_present
      end

      it "should have a login logger event in the queue" do
        expect(LoginEventLogger).to have_queue_size_of(1)
      end
    end

    describe "enqueue with schedule" do
      describe"enqueue_in" do
        subject { new_logger.enqueue_in(2.hours) }

        it "should schedule a login event" do
          subject
          expect(LoginEventLogger).to have_scheduled('login', logger_attrs).in(2.hours)
        end
      end

      describe "enqueue_at" do
        let!(:login_event_logger) { new_logger.enqueue_at later }
        let(:later) { Time.parse "Feb 10 2052" }

        it "should enqueue the login logger to trigger :later" do
          expect(LoginEventLogger).to have_scheduled('login', logger_attrs).at later
        end
      end
    end
  end
end
