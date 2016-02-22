require_relative '../../../lib/event_logger/params'
require_relative '../../toolkits/event_loggers/shared_examples'
require_relative '../../support/test_classes/lib/event_logger/params_test_class'

describe EventLogger::Params, type: :vendor_library do
  include Toolkits::EventLoggers::SharedExamples

  let(:logger_class) { EventLoggerParamsTestClass }
  let(:new_logger) { logger_class.new }
  let(:params) {{ werewolf: "40", badger: "50", war_machine: "60" }}

  before(:each) { allow(new_logger).to receive(:params) { params }}

  it "responds to #numerical_params" do
    expect(logger_class).to respond_to(:numerical_params)
  end

  describe "self.#numerical_params" do
    subject { logger_class.numerical_params(*param_schema) }
    let(:param_schema) { [ :ralph_jones, { :physicist => :stephen_hawking } ] }

    it "defines filtered numerical params for the given param schema" do
      expect(logger_class).to receive(:define_filtered_numerical_param).with(:ralph_jones)
      expect(logger_class).to receive(:define_filtered_numerical_param).with(:physicist, :stephen_hawking)
      subject
    end
  end

  describe "#define_filtered_numerical_param" do
    describe "the defined method" do
      subject { logger_class.new.param_input_name }
      before { logger_class.define_filtered_numerical_param(:param_input_name) }

      it "manipulates the param key with the name of :input_name" do
        expect(logger_class.new.params).to receive("[]").with(:param_input_name)
        subject
      end
    end

    context "only an input name is given" do
      subject { logger_class.define_filtered_numerical_param(:some_input_name) }

      it "defines an instance method called :some_input_name" do
        subject
        expect(logger_class.new).to respond_to(:some_input_name)
      end
    end

    context "an input name and an output name are given" do
      subject { logger_class.define_filtered_numerical_param(:some_input_name, :some_output_name) }

      it "defines an instance method called :some_output_name" do
        subject
        expect(logger_class.new).to respond_to(:some_output_name)
      end
    end
  end

  # shared examples here are defining the input :param_name, and then the :output_name
  # in this instance the :war_machine param is being output as :panzer_tank
  describe "#panzer_tank" do
    it_behaves_like "a numerical param attribute", :war_machine, :panzer_tank
  end

  describe "#werewolf" do
    it_behaves_like "a numerical param attribute", :werewolf, :werewolf
  end

  describe "#badger" do
    it_behaves_like "a numerical param attribute", :badger, :badger
  end
end
