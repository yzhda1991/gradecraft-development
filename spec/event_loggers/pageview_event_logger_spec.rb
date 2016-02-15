require "rails_spec_helper"

# PageviewEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe PageviewEventLogger, type: :background_job do
  let(:new_logger) { PageviewEventLogger.new(logger_attrs) }

  let(:logger_attrs) {{
    course_id: rand(100),
    user_id: rand(100),
    student_id: rand(100),
    user_role: "great role",
    page: "/a/great/path",
    created_at: Time.parse("Jan 20 1972")
  }}

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
      subject { new_logger.enqueue }
      before(:each) { subject }

      it "should find a job in the pageview queue" do
        resque_job = Resque.peek(:pageview_event_logger)
        expect(resque_job).to be_present
      end

      it "should have a pageview logger event in the queue" do
        expect(PageviewEventLogger).to have_queue_size_of(1)
      end
    end

    describe "enqueue with schedule" do
      describe"enqueue_in" do
        let!(:pageview_event_logger) { new_logger.enqueue_in(2.hours) }

        it "should schedule a pageview event" do
          expect(PageviewEventLogger).to have_scheduled('pageview', logger_attrs).in(2.hours)
        end
      end

      describe "enqueue_at" do
        let(:later) { Time.parse "Feb 10 2052" }
        let!(:pageview_event_logger) { new_logger.enqueue_at later }

        it "should enqueue the pageview logger to trigger :later" do
          expect(PageviewEventLogger).to have_scheduled('pageview', logger_attrs).at later
        end
      end
    end
  end
end
