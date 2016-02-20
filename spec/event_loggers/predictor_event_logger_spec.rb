require 'active_record_spec_helper'
require 'resque_spec/scheduler'

require_relative '../toolkits/event_loggers/shared_examples'
require_relative '../toolkits/event_loggers/attributes'
require_relative '../toolkits/event_loggers/event_session'

# PredictorEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe PredictorEventLogger, type: :background_job do
  include InQueueHelper # get help from ResqueSpec
  include Toolkits::EventLoggers::SharedExamples
  include Toolkits::EventLoggers::Attributes
  extend Toolkits::EventLoggers::EventSession

  # pulls in #event_session attributes from EventLoggers::EventSession
  # creates course, user, student objects, and a request double
  define_event_session_with_request

  include InQueueHelper # get help from ResqueSpec

  let(:new_logger) { PredictorEventLogger.new(event_session) }
  let(:logger_attrs) { predictor_logger_attrs } # pulled in from Toolkits::EventLoggers::Attributes

  # shared examples for EventLogger subclasses
  it_behaves_like "an EventLogger subclass", PredictorEventLogger, "predictor"
  it_behaves_like "EventLogger::Enqueue is included", PredictorEventLogger, "predictor"

  let(:params) {{ assignment: "40", score: "50", possible: "60" }}
  let(:param_attrs) {{ assignment_id: 40, score: 50, possible: 60 }}

  describe "#event_attrs" do
    subject { new_logger.event_attrs }

    before(:each) do
      new_logger.instance_variable_set(:@event_attrs, nil)
      allow(new_logger).to receive(:params) { params }
    end

    it "merges the param_attrs from the original request with the base_attrs" do
      expect(subject).to eq new_logger.base_attrs.merge(param_attrs)
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

  describe "#param_attrs" do
    before { allow(new_logger).to receive_messages(param_attrs) }
    it "builds a hash from the filtered param attribute values" do
      expect(new_logger.param_attrs).to eq(param_attrs)
    end
  end

  describe "params attributes" do
    before(:each) { allow(new_logger).to receive(:params) { params }}

    describe "#assignment_id" do
      subject { new_logger.assignment_id }

      context "params[:assignment] exists" do
        let(:params) {{ assignment: "40" }}
        it "returns the assignment value as an integer" do
          expect(subject).to eq(40)
        end
      end

      context "params[:assignment] does not exist" do
        let(:params) {{ waffles: "40" }}
        it "returns nil" do
          expect(subject).to be_nil
        end
      end
    end

    describe "#score" do
      subject { new_logger.score }

      context "params[:score] exists" do
        let!(:params) {{ score: "40" }}
        it "returns the score value as an integer" do
          expect(subject).to eq(40)
        end
      end

      context "params[:score] does not exist" do
        let!(:params) {{ waffles: "40" }}
        it "returns nil" do
          expect(subject).to be_nil
        end
      end
    end

    describe "#possible" do
      subject { new_logger.possible }

      context "params[:possible] exists" do
        let(:params) {{ possible: "40" }}
        it "returns the possible value as an integer" do
          expect(subject).to eq(40)
        end
      end

      context "params[:possible] does not exist" do
        let(:params) {{ waffles: "40" }}
        it "returns nil" do
          expect(subject).to be_nil
        end
      end
    end
  end
end
