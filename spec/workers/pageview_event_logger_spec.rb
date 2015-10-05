require 'spec_helper'

# PageviewEventLogger.new(pageview_logger_attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe PageviewEventLogger, type: :background_job do
  describe "#enqueue_in" do
    context "a user is logged in and the request is formatted as html" do
      before(:each) do
        ResqueSpec.reset!
      end

      context "enqueue without schedule" do
        it "should find a job in the pageview queue" do
          @pageview_logger = PageviewEventLogger.new(pageview_logger_attrs).enqueue
          resque_job = Resque.peek(:pageview_event_logger)
          puts "Job is #{resque_job}"
          expect(resque_job).to be_present
        end

        it "should have a pageview logger event in the queue" do
          @pageview_logger = PageviewEventLogger.new(pageview_logger_attrs).enqueue
          expect(PageviewEventLogger).to have_queue_size_of(1)
        end
      end

      context "enqueue with schedule" do
        it "should schedule a pageview event" do
          @pageview_logger = PageviewEventLogger.new(pageview_logger_attrs).enqueue_in(2.hours)
          @pageview_logger = PageviewEventLogger.new(pageview_logger_attrs).enqueue_in(1)
          expect(PageviewEventLogger).to have_scheduled('pageview', pageview_logger_attrs).in(2.hours)
        end
      end
    end
  end

  def pageview_logger_attrs
    {
      course_id: 50,
      user_id: 70,
      student_id: 90,
      user_role: "great role",
      page: "/a/great/path",
      created_at: Time.parse("Jan 20 1972")
    }
  end
  
end
