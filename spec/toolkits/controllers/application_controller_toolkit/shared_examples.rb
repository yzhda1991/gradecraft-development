module Toolkits
  module Controllers
    module ApplicationControllerToolkit
      module SharedExamples

        RSpec.shared_examples "no EventLogger is built unless a user is logged in" do |logger_class|
          let(:logger_event_type) { logger_class.to_s.gsub("EventLogger","").downcase }

          # if current_user
          context "no user is logged in" do
            it "should not call #{described_class}" do
              allow(controller).to receive_messages(current_user: nil)
              expect(logger_class).not_to receive(:new).with event_session
              subject
            end
          end

        end
      end
    end
  end
end
