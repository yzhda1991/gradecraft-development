module Toolkits
  module Controllers
    module ApplicationControllerToolkit
      module SharedExamples

        RSpec.shared_examples "an EventLogger triggered by filter" do |logger_class|
          let(:logger_event_type) { logger_class.to_s.gsub("EventLogger","").downcase }

          # if current_user && request.format.html?
          context "no user is logged in" do
            it "should not call #{described_class}" do
              allow(controller).to receive_messages(current_user: nil)
              expect(logger_class).not_to receive(:new).with logger_attrs
              get :html_page
            end
          end

          context "the request is not html" do
            it "should not call #{described_class}" do
              stub_current_user
              expect(logger_class).not_to receive(:new).with logger_attrs
              get :json_page, format: "json"
            end
          end

          context "a user is logged in and the request is formatted as html" do
            before(:each) do
              stub_current_user
              allow(Lull).to receive_messages(time_until_next_lull: 2.hours)
              @event_logger = double(:event_logger)
              @enqueue_response = double(:enqueue_response)
              allow(@event_logger).to receive_messages(enqueue_in: @enqueue_response)
              allow(logger_class).to receive_messages(new: @event_logger)
            end

            it "should create a new #{logger_class.to_s} object" do
              expect(logger_class).to receive(:new).with(logger_attrs) { @event_logger }
            end

            it "should enqueue the new #{logger_class.to_s} object in 2 hours" do
              expect(@event_logger).to receive(:enqueue_in).with(2.hours) { @enqueue_response }
            end

            after(:each) do
              get :html_page
            end
          end

          context "Resque fails to reach Redis and returns a getaddrinfo socket error" do
            before do
              stub_current_user
              allow(logger_class).to receive(:new).and_raise("Could not connect to Redis: getaddrinfo socket error.")
            end

            it "performs the #{logger_class} event log directly from the controller" do
              expect(logger_class).to receive(:perform).with(logger_event_type, logger_attrs)
              get :html_page
            end

            it "adds an additional record to mongo" do
              expect { get :html_page }.to change{ logger_class.instance_variable_get(:@analytics_class).count }.by(1)
            end
          end
        end

      end
    end
  end
end
