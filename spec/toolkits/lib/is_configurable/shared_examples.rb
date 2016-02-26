module Toolkits
  module Lib
    module IsConfigurableToolkit
      module SharedExamples

        RSpec.shared_examples "it is configurable" do |target_class, demo_config|
          let(:configuration) { target_class.configuration }
          let(:new_configuration) { target_class::Configuration.new }

          let(:apply_demo_config) do
            target_class.configure do |config|
              demo_config.each do |config_attr, value|
                config.send("#{config_attr}=", value)
              end
            end
          end

          describe "writeable attributes" do
            it "should be able to write a configuration" do
              target_class.configuration = new_configuration
              expect(target_class.configuration).to eq(new_configuration)
            end
          end

          describe "#configuration" do
            subject { target_class.configuration }

            it "should build a new ::Configuration object in the target class" do
              expect(subject.class).to eq(target_class::Configuration)
            end

            it "should cache the configuration" do
              subject
              expect(target_class::Configuration).not_to receive(:new)
              subject
            end

            it "should set the configuration to @configuration" do
              subject
              expect(target_class.instance_variable_get(:@configuration).class)
                .to eq(target_class::Configuration)
            end
          end

          describe "#reset_configuration" do
            before { apply_demo_config }

            it "should reset the configuration" do
              target_class.reset_configuration
              demo_config.keys.each do |config_attr|
                expect(configuration.send(config_attr))
                  .to eq(new_configuration.send(config_attr))
              end
            end
          end

          describe "#configure" do
            before { apply_demo_config }

            it "should expose the configuration for modification as a block" do
              demo_config.each do |config_attr, value|
                expect(configuration.send(config_attr)).to eq(value)
              end
            end
          end
        end

      end
    end
  end
end
