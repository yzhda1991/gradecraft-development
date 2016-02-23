module Toolkits
  module Lib
    module ResqueRetryToolkit
      module SharedExamples
        RSpec.shared_examples "it uses a configurable backoff strategy" do |target_class, config_class|
          subject { target_class.backoff_strategy }
          let(:configured_value) { config_class.configuration.backoff_strategy }

          it "should use the configured default #backoff_strategy for resque-retry" do
            expect(subject).to eq(configured_value)
          end

          it "should cache the value" do
            subject
            expect(config_class).not_to receive(:configuration)
            subject
          end

          it "should set a class-level instance variable of #backoff_strategy" do
            expect(described_class.instance_variable_get(:@backoff_strategy)).to eq(configured_value)
          end
        end
      end
    end
  end
end
