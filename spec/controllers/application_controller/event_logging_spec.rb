require 'rails_spec_helper'
require 'resque-scheduler'
require 'resque_spec/scheduler'

# define routes for mapping #html_page and #json_page to the test controller
include Toolkits::Controllers::ApplicationControllerToolkit::Routes
include Toolkits::Controllers::ApplicationControllerToolkit::SharedExamples

RSpec.describe ApplicationControllerEventLoggingTest do
  extend Toolkits::EventLoggers::EventSession

  # pulls in #event_session attributes from EventLoggers::EventSession
  # creates course, user, student objects, uses native controller request variable
  define_event_session

  before do
    allow(user).to receive_messages(current_course: course)
    define_event_logging_test_routes # pulled in from Toolkits::Controllers::ApplicationControllerToolkit::Routes
    allow(controller).to receive_messages(current_user: user, event_session: event_session)
  end

  describe "triggering pageview logger events" do
    subject { get :html_page }

    let(:logger_class) { PageviewEventLogger }

    it_behaves_like "no EventLogger is built unless a user is logged in", PageviewEventLogger

    # if current_user
    context "no user is logged in" do
      it "should not call #{described_class}" do
        allow(controller).to receive_messages(current_user: nil)
        expect(logger_class).not_to receive(:new).with event_session
        subject
      end
    end

    context "a user is logged in and the request is for html" do
      let(:event_logger) { logger_class.new }
      let(:enqueue_response) { double(:enqueue_response) }

      before(:each) do
        allow(Lull).to receive_messages(time_until_next_lull: 2.hours)
        allow(event_logger).to receive_messages(enqueue_in: enqueue_response)
        allow(logger_class).to receive_messages(new: event_logger)
      end

      it "should create a new PageviewEventLogger" do
        expect(logger_class).to receive(:new).with(event_session) { event_logger }
      end

      it "should enqueue the new pageview event in 2 hours" do
        expect(event_logger).to receive(:enqueue_in_with_fallback).with(2.hours) { enqueue_response }
      end

      after(:each) { subject }
    end

    context "the request is not html" do
      it "should not call #{described_class}" do
        expect(PageviewEventLogger).not_to receive(:new).with event_session
        get :json_page, format: "json"
      end
    end
  end

  describe "#record_course_login_event" do
    subject { controller.instance_eval { record_course_login_event }}

    let(:logger_class) { LoginEventLogger }

    before do
      create :professor_course_membership, course: course, user: user
    end

    it_behaves_like "no EventLogger is built unless a user is logged in", LoginEventLogger
    context "a user is logged in and the request is for either html or xml" do
      let(:event_logger) { logger_class.new }
      let(:enqueue_response) { double(:enqueue_response) }

      before(:each) do
        allow(event_logger).to receive_messages(enqueue: enqueue_response)
        allow(logger_class).to receive_messages(new: event_logger)
      end

      it "should create a new login event" do
        expect(logger_class).to receive(:new).with(event_session) { event_logger }
      end

      it "should enqueue the new login event" do
        expect(event_logger).to receive(:enqueue_with_fallback) { enqueue_response }
      end

      after(:each) { subject }
    end

    context "the request is not html or xml" do
      let(:format) {{ html?: false, xml?: false, json?: true }}

      it "should not call #{described_class}" do
        allow(controller.request.format).to receive_messages(format)
        expect(PageviewEventLogger).not_to receive(:new).with event_session
        subject
      end
    end
  end

  after do
    # reload the proper routes to clear out custom /html_page and /json_page routes
    Rails.application.reload_routes!
  end
end
