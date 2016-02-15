require 'rails_spec_helper'

include LoginEventLoggerToolkit # login_logger_attrs comes from here

# LoginEventLogger.new(login_logger_attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe LoginEventLogger, type: :background_job do
  describe "initialize" do
    it "should set an @attrs hash" do
      @some_attrs = { goats: 10, hillbilly_name: "Jake" }
      @login_logger = LoginEventLogger.new(@some_attrs)
      expect(@login_logger.instance_variable_get(:@attrs)).to eq(@some_attrs)
    end
  end

  describe "enqueuing" do
    before(:each) do
      ResqueSpec.reset!
    end

    describe "enqueue without schedule" do
      it "should find a job in the login queue" do
        @login_logger = LoginEventLogger.new(login_logger_attrs).enqueue
        resque_job = Resque.peek(:login_event_logger)
        puts "Job is #{resque_job}"
        expect(resque_job).to be_present
      end

      it "should have a login logger event in the queue" do
        @login_logger = LoginEventLogger.new(login_logger_attrs).enqueue
        expect(LoginEventLogger).to have_queue_size_of(1)
      end
    end

    describe "enqueue with schedule" do

      describe"enqueue_in" do
        it "should schedule a login event" do
          @login_logger = LoginEventLogger.new(login_logger_attrs).enqueue_in(2.hours)
          expect(LoginEventLogger).to have_scheduled('login', login_logger_attrs).in(2.hours)
        end
      end

      describe "enqueue_at" do
        it "should enqueue the login logger to trigger @later" do
          @later = Time.parse "Feb 10 2052"
          @login_logger = LoginEventLogger.new(login_logger_attrs).enqueue_at(@later)
          expect(LoginEventLogger).to have_scheduled('login', login_logger_attrs).at(@later)
        end
      end
    end
  end
end
