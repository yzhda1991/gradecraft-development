require 'rails_spec_helper'

include PageviewEventLoggerToolkit # pageview_logger_attrs comes from here

# PageviewEventLogger.new(pageview_logger_attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe PageviewEventLogger, type: :background_job do
  describe "initialize" do
    it "should set an @attrs hash" do
      @some_attrs = { goats: 10, hillbilly_name: "Jake" }
      @pageview_logger = PageviewEventLogger.new(@some_attrs)
      expect(@pageview_logger.instance_variable_get(:@attrs)).to eq(@some_attrs)
    end
  end

  describe "enqueuing" do
    before(:each) do
      ResqueSpec.reset!
    end

    describe "enqueue without schedule" do
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

    describe "enqueue with schedule" do

      describe"enqueue_in" do
        it "should schedule a pageview event" do
          @pageview_logger = PageviewEventLogger.new(pageview_logger_attrs).enqueue_in(2.hours)
          expect(PageviewEventLogger).to have_scheduled('pageview', pageview_logger_attrs).in(2.hours)
        end
      end

      describe "enqueue_at" do
        it "should enqueue the pageview logger to trigger @later" do
          @later = Time.parse "Feb 10 2052"
          @pageview_logger = PageviewEventLogger.new(pageview_logger_attrs).enqueue_at(@later)
          expect(PageviewEventLogger).to have_scheduled('pageview', pageview_logger_attrs).at(@later)
        end
      end
    end
  end
end
