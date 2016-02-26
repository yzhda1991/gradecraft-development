require "active_record_spec_helper"
require "resque_spec/scheduler"

require_relative "../toolkits/event_loggers/shared_examples"
require_relative "../toolkits/event_loggers/attributes"
require_relative "../toolkits/event_loggers/event_session"

# PredictorEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe PredictorEventLogger, type: :event_logger do
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

    context "params exists" do
      it "merges the param_attrs from the original request with the base_attrs" do
        expect(subject).to eq new_logger.base_attrs.merge(param_attrs)
      end
    end

    context "params does not exist" do
      let(:params) { nil }
      it "simply returns the base_attrs" do
        expect(subject).to eq new_logger.base_attrs
      end
    end

    it_behaves_like "#event_attrs that are cached in @event_attrs"
  end

  describe "#param_attrs" do
    before { allow(new_logger).to receive_messages(param_attrs) }
    it "builds a hash from the filtered param attribute values" do
      expect(new_logger.param_attrs).to eq(param_attrs)
    end
  end

  describe "params attributes" do
    before(:each) { allow(new_logger).to receive(:params) { params }}

    # shared examples here are defining the input :param_name, and then the :output_name
    # in this instance the :assignment param is being output as :assignment_id
    describe "#assignment_id" do
      it_behaves_like "a numerical param attribute", :assignment, :assignment_id
    end

    describe "#score" do
      it_behaves_like "a numerical param attribute", :score, :score
    end

    describe "#possible" do
      it_behaves_like "a numerical param attribute", :possible, :possible
    end
  end
end
