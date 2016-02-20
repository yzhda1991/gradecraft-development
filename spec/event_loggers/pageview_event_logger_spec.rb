require "active_record_spec_helper"
require "resque_spec/scheduler"

require_relative "../toolkits/event_loggers/shared_examples"
require_relative "../toolkits/event_loggers/attributes"
require_relative "../toolkits/event_loggers/event_session"
require_relative "../toolkits/event_loggers/application_event_logger_toolkit"

# PageviewEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe PageviewEventLogger, type: :background_job do
  include InQueueHelper # get help from ResqueSpec
  include Toolkits::EventLoggers::SharedExamples
  include Toolkits::EventLoggers::Attributes
  include Toolkits::EventLoggers::ApplicationEventLoggerToolkit
  extend Toolkits::EventLoggers::EventSession

  # pulls in #event_session attributes from EventLoggers::EventSession
  # creates course, user, student objects, and a request double
  define_event_session_with_request

  let(:new_logger) { PageviewEventLogger.new(event_session) }
  let(:expected_base_attrs) { application_logger_base_attrs } # pulled in from Toolkits::EventLoggers::ApplicationEventLoggerToolkit

  # shared examples for EventLogger subclasses
  it_behaves_like "an EventLogger subclass", PageviewEventLogger, "pageview"
  it_behaves_like "EventLogger::Enqueue is included", PageviewEventLogger, "pageview"

  describe "#event_attrs" do
    subject { new_logger.event_attrs }

    before { allow(new_logger).to receive(:page) { "some great page" } }

    it "merges the page from the original request with the base_attrs" do
      expect(subject).to eq new_logger.base_attrs.merge(page: "some great page")
    end

    it_behaves_like "#event_attrs that are cached in @event_attrs"
  end

  describe "#page" do
    subject { new_logger.page }
    let(:request_path) { "/path/to/chaos" }

    before do
      allow(request).to receive(:original_fullpath) { request_path }
    end

    it "gets the original fullpath from the request" do
      expect(subject).to eq request_path
    end

    it "caches the #page" do
      subject
      expect(request).not_to receive(:try).with(:original_fullpath)
      subject
    end

    it "sets the page to @page" do
      subject
      expect(new_logger.instance_variable_get(:@page)).to eq(request_path)
    end
  end

  describe "#build_page_from_params" do
    subject { new_logger.build_page_from_params }
    before(:each) { allow(new_logger).to receive(:params) { params }}

    context "params exists" do
      context "params[:url] and params[:tab] don't exists" do
        let(:params) {{ stuff: "dude" }}
        it "returns nil" do
          expect(subject).to be_nil
        end
      end

      context "params[:url] and params[:tab] both exist" do
        let(:params) {{ url: "http://some.url", tab: "#greatness" }}
        it "builds a string from the params :url and :tab values" do
          expect(subject).to eq("http://some.url#greatness")
        end

        it "sets @page to the string built from \#{url}\#{tab}" do
          subject
          expect(new_logger.instance_variable_get(:@page)).to eq("http://some.url#greatness")
        end
      end
    end

    context "params does not exist" do
      let(:params) { nil }
      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end
end
