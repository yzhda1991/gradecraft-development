require_relative '../support/test_classes/lib/is_configurable/is_configurable_test_class'

describe IsConfigurable, type: :vendor_library do
  let(:configurable_class) { IsConfigurableTestClass }
  let(:configuration) { configurable_class.configuration }
  let(:apply_configuration) do
    configurable_class.configure do |config|
      config.waffle_name = "blueberry"
      config.pancake_size = 30
    end
  end

  describe "writeable attributes" do
    it "should be able to write a configuration" do
      configurable_class.configuration = "hamhocks"
      expect(configurable_class.configuration).to eq("hamhocks")
    end
  end

  describe "#configuration" do
    subject { configurable_class.configuration }

    it "should build a new ::Configuration object in the target class" do
      expect(subject.class).to eq(configurable_class::Configuration)
    end

    it "should cache the configuration" do
      subject
      expect(configurable_class::Configuration).not_to receive(:new)
      subject
    end

    it "should set the configuration to @configuration" do
      subject
      expect(configurable_class.instance_variable_get(:@configuration).class)
        .to eq(configurable_class::Configuration)
    end
  end

  describe "#reset_configuration" do
    before { apply_configuration }

    it "should reset the configuration" do
      configurable_class.reset_configuration
      expect(configuration.waffle_name).to be_nil
      expect(configuration.pancake_size).to be_nil
    end
  end

  describe "#configure" do
    before { apply_configuration }

    it "should expose the configuration for modification as a block" do
      expect(configuration.waffle_name).to eq("blueberry")
      expect(configuration.pancake_size).to eq(30)
    end
  end
end
