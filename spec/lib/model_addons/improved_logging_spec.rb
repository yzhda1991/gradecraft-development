require "spec_helper"

# test logging on a waffle
class Waffle
  include ModelAddons::ImprovedLogging

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def attributes
    { some_attr: "great_stuff" }
  end
end

RSpec.describe ModelAddons::ImprovedLogging, type: :vendor_library do
  before { @waffle = Waffle.new }

  describe "log_with_attributes" do
    context "called with a valid logging type" do
      it "logs a message with the correct type and output" do
        formatted_output = @waffle.instance_eval { formatted_log_output("snakes are great") }
        expect(@waffle.logger).to receive(:send).with(:info, formatted_output)
        @waffle.log_with_attributes(:info, "snakes are great")
      end
    end

    context "called with an invalid logging type" do
      it "logs an error message" do
        invalid_logger_message = @waffle.instance_eval { invalid_logging_type_message }
        expect(@waffle.logger).to receive(:send).with(:error, invalid_logger_message)
        @waffle.log_with_attributes(:invalid_type, "snakes are erroneous")
      end
    end
  end

  describe "log_error_with_attributes" do
    it "logs a message with type :error" do
      expect(@waffle).to receive(:log_with_attributes).with(:error, "error stuff")
      @waffle.log_error_with_attributes("error stuff")
    end
  end

  describe "log_info_with_attributes" do
    it "logs a message with type :info" do
      expect(@waffle).to receive(:log_with_attributes).with(:info, "info stuff")
      @waffle.log_info_with_attributes("info stuff")
    end
  end

  describe "log_warning_with_attributes" do
    it "logs a message with type :warn" do
      expect(@waffle).to receive(:log_with_attributes).with(:warn, "warning stuff")
      @waffle.log_warning_with_attributes("warning stuff")
    end
  end

  describe "valid_logging_types" do
    it "returns an array of the valid logging message types" do
      expect(@waffle.instance_eval { valid_logging_types }).to eq([:debug, :info, :warn, :error, :fatal])
    end
  end

  describe "formatted_log_output" do
    it "formats the logger message" do
      expected_message = "robbers are here!! in object #{@waffle}.\n#{@waffle} attributes: #{@waffle.attributes}"
      expect(@waffle.instance_eval { formatted_log_output("robbers are here!!") }).to eq(expected_message)
    end
  end

  describe "invalid_logging_type_message" do
    it "returns a formatted message regarding the logging error" do
      message = "Attempted to log with an incorrect type in ModelAddons::ImprovedLogging#log_with_attributes"
      expect(@waffle).to receive(:formatted_log_output).with(message)
      @waffle.instance_eval { invalid_logging_type_message }
    end
  end
end
