module Toolkits
  module Performers
    module AssignmentExport

      RSpec.shared_examples "an expandable messages hash" do
        it "expands the base messages" do
          expect(performer).to receive(:expand_messages)
          subject
        end
      end

      RSpec.shared_examples "it has a success message" do |message|
        it "has a success message" do
          expect(subject[:success]).to match(message)
        end
      end

      RSpec.shared_examples "it has a failure message" do |message|
        it "has a failure message" do
          expect(subject[:failure]).to match(message)
        end
      end
    end
  end
end
