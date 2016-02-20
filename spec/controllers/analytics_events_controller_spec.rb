require "rails_spec_helper"
require "resque-scheduler"
require "resque_spec/scheduler"

describe AnalyticsEventsController, type: :controller do
  extend Toolkits::EventLoggers::EventSession

  # pulls in #event_session attributes from EventLoggers::EventSession
  # creates course, user, student objects, uses native controller request variable
  define_event_session

  let(:event_session_with_params) { event_session.merge(params) }
  let(:params) {{ assignment: "40", score: "50", possible: "60" }}

  before do
    allow(user).to receive_messages(current_course: course)
    allow(controller).to receive_messages({
      current_user: user,
      event_session: event_session,
      event_session_with_params: event_session_with_params
    })
  end

  describe "POST #predictor_event" do
    subject { post :predictor_event }

    let(:logger_class) { PredictorEventLogger }

    context "a user is logged in and the request is for html" do
      let(:event_logger) { logger_class.new }
      let(:enqueue_response) { double(:enqueue_response) }

      before(:each) do
        allow(logger_class).to receive_messages(new: event_logger)
      end

      it "should create a new PredictorEventLogger" do
        expect(logger_class).to receive(:new).with(event_session_with_params) { event_logger }
        subject
      end

      it "should enqueue the new PredictorEventLogger object with fallback" do
        expect(event_logger).to receive(:enqueue_with_fallback)
        subject
      end

      it "should not increment page views" do
        expect(controller).not_to receive(:increment_page_views)
        subject
      end

      it "should render nothing" do
        subject
        expect(response.body).to be_empty
      end

      it "should render an :ok response" do
        subject
        expect(response.status).to eq(200)
      end
    end
  end
end
