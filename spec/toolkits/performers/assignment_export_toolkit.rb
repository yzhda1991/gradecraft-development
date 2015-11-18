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

      RSpec.shared_examples "a created student directory" do |dir_path|
        it "actually creates the directory on disk" do
          subject
          expect(File.exist?(dir_path)).to be_truthy
        end

        it "makes a directory for the student path" do
          expect(Dir).to receive(:mkdir).with(dir_path)
          subject
        end
      end

    end
  end
end
