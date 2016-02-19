module Toolkits
  module Controllers
    module ApplicationControllerToolkit
      module SharedExamples

        RSpec.shared_examples "an EventLogger calling #enqueue_in_with_fallback" do |logger_class|
          let(:logger_event_type) { logger_class.to_s.gsub("EventLogger","").downcase }

          # if current_user
          context "no user is logged in" do
            it "should not call #{described_class}" do
              allow(controller).to receive_messages(current_user: nil)
              expect(logger_class).not_to receive(:new).with event_session
              subject
            end
          end

          context "a user is logged in and the request is formatted as html" do
            let(:event_logger) { logger_class.new }
            let(:enqueue_response) { double(:enqueue_response) }

            before(:each) do
              stub_current_user
              allow(Lull).to receive_messages(time_until_next_lull: 2.hours)
              allow(event_logger).to receive_messages(enqueue_in: enqueue_response)
              allow(logger_class).to receive_messages(new: event_logger)
            end

            it "should create a new #{logger_class.to_s} object" do
              expect(logger_class).to receive(:new).with(event_session) { event_logger }
            end

            it "should enqueue the new #{logger_class.to_s} object in 2 hours" do
              expect(event_logger).to receive(:enqueue_in).with(2.hours) { enqueue_response }
            end

            after(:each) { subject }
          end
        end
      end
    end
  end
end
