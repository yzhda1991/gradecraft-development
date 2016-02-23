require "logglier"
require_relative "../../../lib/resque_job/base"
require_relative "../../../lib/resque_job/performer"
require_relative "../../../lib/inheritable_ivars"
require_relative "../../../lib/loggly_resque"
require_relative "../../toolkits/lib/inheritable_ivars/shared_examples"
require_relative "../../toolkits/lib/loggly_resque/shared_examples"

describe ResqueJob::Base, type: :vendor_library do
  include Toolkits::Lib::InheritableIvarsToolkit::SharedExamples
  include Toolkits::Lib::LogglyResqueToolkit::SharedExamples

  let(:backoff_strategy) { [0, 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360, 420, 540, 660, 780, 900, 1140, 1380, 1520, 1760, 3600, 7200, 14400, 28800] }
  let(:successful_outcome) { double(:outcome, message: "great things happened", success?: true, failure?: false, result_excerpt: "great thi" ) }
  let(:failed_outcome) { double(:outcome, message: "bad things happened", failure?: true, success?: false, result_excerpt: "bad thin") }
  let(:outcomes) { [ successful_outcome, failed_outcome ] }
  let(:logger) { double(Logger).as_null_object }

  describe "extensions" do
    it "should use resque-retry" do
      expect(ResqueJob::Base).to respond_to(:retry_delay)
    end
  end

  describe "class-level instance variable defaults" do
    it "should have a default @queue" do
      ResqueJob::Base.instance_variable_set(:@queue, :herman)
      expect(ResqueJob::Base.instance_variable_get(:@queue)).to eq(:herman)
    end

    it "should have a default @performer_class" do
      expect(ResqueJob::Base.instance_variable_get(:@performer_class)).to eq(ResqueJob::Performer)
    end

    it "should not have a default @retry_limit for resque-retry" do
      expect(ResqueJob::Base.instance_variable_get(:@retry_limit)).to eq(nil)
    end

    it "should not have a default @retry_delay for resque-retry" do
      expect(ResqueJob::Base.instance_variable_get(:@retry_delay)).to eq(nil)
    end

    it "should have a default #backoff_strategy for resque-retry" do
      expect(ResqueJob::Base.backoff_strategy).to eq(backoff_strategy)
    end
  end

  describe "#backoff_strategy" do
    subject { ResqueJob::Base.backoff_strategy }
    let(:configured_value) { ResqueJob.configuration.backoff_strategy }

    it "should use the configured default #backoff_strategy for resque-retry" do
      expect(subject).to eq(configured_value)
    end

    it "should cache the value" do
      subject
      expect(ResqueJob).not_to receive(:configuration)
      subject
    end

    it "should set a class-level instance variable of #backoff_strategy" do
      expect(described_class.instance_variable_get(:@backoff_strategy)).to eq(configured_value)
    end
  end

  describe "self.perform(attrs={})" do
    let(:attrs) {{ hounds: 5, teeth: 9 }}
    let(:performer) { double(:performer).as_null_object }

    before(:each) do
      allow(ResqueJob::Performer).to receive_messages(new: performer)
      allow(ResqueJob::Base).to receive(:logger) { logger }
      allow(ResqueJob::Base).to receive_messages(start_message: "waffles have started")
      allow(performer).to receive(:outcomes) { outcomes }
    end

    after(:each) do
      ResqueJob::Base.perform(attrs)
    end

    it "should print a start message" do
      allow(ResqueJob::Base).to receive_messages(start_message: "waffles have started")
      expect(logger).to receive(:info).with("waffles have started")
    end

    it "should build a new performer" do
      expect(ResqueJob::Performer).to receive(:new).with(attrs, logger)
    end

    it "should have the performer do the work" do
      expect(performer).to receive(:do_the_work)
    end

    it "should log the outcome messages" do
      expect(ResqueJob::Base).to receive(:log_outcomes).with(performer.outcomes)
    end
  end

  describe "self#log_outcomes" do
    subject { ResqueJob::Base.log_outcomes(outcomes) }
    before { allow(ResqueJob::Base).to receive(:logger) { logger }}

    it "logs the message and a result excerpt for all outcomes" do
      expect(logger).to receive(:info).with("SUCCESS: #{successful_outcome.message}").once
      expect(logger).to receive(:info).with("RESULT: #{successful_outcome.result_excerpt}").once
      expect(logger).to receive(:info).with("FAILURE: #{failed_outcome.message}").once
      expect(logger).to receive(:info).with("RESULT: #{failed_outcome.result_excerpt}").once
      subject
    end
  end

  describe "instantiation" do
    let(:attrs) {{ snakes: 10, steve: true }}

    it "should build an instance successfully" do
      expect(ResqueJob::Base.new(attrs).class).to eq(ResqueJob::Base)
    end

    it "should pass attributes to the instance" do
      instance = ResqueJob::Base.new(attrs)
      expect(instance.instance_variable_get(:@attrs)).to eq(attrs)
    end
  end

  describe "subclass inheritance" do
    it "inherits the inclusion of Resque::Plugins::ExponentialBackoff" do
      class PseudoResqueJob < ResqueJob::Base; end
      expect(PseudoResqueJob.retry_delay_multiplicand_min).to eq(1.0) # default from resque-retry
    end
  end

  describe "self.start_message" do
    let(:attrs) {{ snakes: 10, steve: true }}

    context "class has a @start_message class-level instance variable" do
      it "should return the @start_message value" do
        ResqueJob::Base.instance_variable_set(:@start_message, "stuff started!!")
        expect(ResqueJob::Base.start_message(attrs)).to eq("stuff started!!")
      end
    end

    context "class doens't have a @start_message variable" do
      before do
        ResqueJob::Base.instance_variable_set(:@start_message, nil)
        ResqueJob::Base.instance_variable_set(:@queue, :snake)
        allow(ResqueJob::Base).to receive_messages(job_type: "terrible job")
      end

      it "should return a start message with job_type and queue" do
        expected_message = "Starting terrible job in queue 'snake' with attributes {:snakes=>10, :steve=>true}."
        expect(ResqueJob::Base.start_message(attrs)).to eq(expected_message)
      end
    end

    describe "self.job_type" do
      it "should be the class stringified" do
        expect(ResqueJob::Base.job_type).to eq("ResqueJob::Base")
      end

      context "subclasses" do
        it "should not use the module name in subclasses" do
          class WeirdJob < ResqueJob::Base; end
          expect(WeirdJob.job_type).to eq("WeirdJob")
        end
      end
    end

    describe "self.object_class" do
      it "should return the class object of an instance of the class" do
        expect(ResqueJob::Base.object_class).to eq(ResqueJob::Base)
      end

      context "subclasses" do
        it "should not use the module name in subclasses" do
          class WeirdJob < ResqueJob::Base; end
          expect(WeirdJob.object_class).to eq(WeirdJob)
        end
      end
    end
  end

  # test whether @ivars are properly inheritable after extending the
  # InheritableIvars module, pulled in from shared examples in the
  # InheritableIvarsToolit. Defined in:
  # /spec/toolkits/lib/inheritable_ivars/shared_examples
  it_behaves_like "some @ivars are inheritable by subclasses", ResqueJob::Base

  describe "self.inheritable_ivars" do
    let(:expected_attrs) {[
      :queue,
      :performer_class,
      :backoff_strategy
    ]}

    it "should have a list of inheritable attributes" do
      expect(described_class.inheritable_ivars).to eq(expected_attrs)
    end
  end

  describe "the logger implementation" do
    it_behaves_like "the #logger is implemented through Logglier with LogglyResque", described_class
  end

end
