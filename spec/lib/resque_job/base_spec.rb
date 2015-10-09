require 'spec_helper'

RSpec.describe ResqueJob::Base, type: :vendor_library do
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

    it "should have a default @retry_limit for resque-retry" do
      expect(ResqueJob::Base.instance_variable_get(:@retry_limit)).to eq(3)
    end

    it "should have a default @retry_delay for resque-retry" do
      expect(ResqueJob::Base.instance_variable_get(:@retry_delay)).to eq(60)
    end
  end

  describe "self.perform(attrs={})" do
    before do
      @attrs = { hounds: 5, teeth: 9 }
    end

    before(:each) do
      @performer = double(:performer).as_null_object
      allow(ResqueJob::Performer).to receive_messages(new: @performer)
    end

    after(:each) do
      ResqueJob::Base.perform(@attrs)
    end

    it "should print a start message" do
      allow(ResqueJob::Base).to receive_messages(start_message: "waffles have started")
      expect(ResqueJob::Base).to receive(:p).with("waffles have started")
    end

    it "should build a new performer" do
      expect(ResqueJob::Performer).to receive(:new).with(@attrs)
    end

    it "should have the performer do the work" do
      expect(@performer).to receive(:do_the_work)
    end

    it "should have the performer do the work" do
      expect(@performer).to receive(:puts_outcome_messages)
    end
  end

  describe "instantiation" do
    before do
      @attrs = { snakes: 10, steve: true }
    end

    it "should build an instance successfully" do
      expect(ResqueJob::Base.new(@attrs).class).to eq(ResqueJob::Base)
    end

    it "should pass attributes to the instance" do
      instance = ResqueJob::Base.new(@attrs)
      expect(instance.instance_variable_get(:@attrs)).to eq(@attrs)
    end
  end

  describe "subclass inheritance" do
    it "should pass class-level instance variables to subclasses" do
      ResqueJob::Base.instance_variable_set(:@wallaby_necks, 5)
      allow(ResqueJob::Base).to receive(:instance_variable_names).and_return ["@wallaby_necks"]
      class WallabyResqueJob < ResqueJob::Base; end
      expect(WallabyResqueJob.instance_variable_get(:@wallaby_necks)).to eq(5)
    end

    it "should pass some actual values to subclasses" do
      class PseudoResqueJob < ResqueJob::Base; end
      expect(PseudoResqueJob.instance_variable_get(:@retry_limit)).to eq(3)
      expect(PseudoResqueJob.instance_variable_get(:@retry_delay)).to eq(60)
    end
  end

  describe "self.instance_variable_names" do
    before do
      @class_ivars = { ostriches: 50, badgers: 24 }
      allow(ResqueJob::Base).to receive_messages(class_level_instance_variables: @class_ivars)
    end

    it "should return an array of instance variable names" do
      expect(ResqueJob::Base.instance_variable_names).to include("@ostriches", "@badgers")
    end
  end

  describe "self.class_level_instance_variables" do
    it "should return a hash of ivar-value pairs" do
      expect(ResqueJob::Base.class_level_instance_variables.class).to eq(Hash)
    end
  end

  describe "self.start_message" do
    context "class has a @start_message class-level instance variable" do
      it "should return the @start_message value" do
        ResqueJob::Base.instance_variable_set(:@start_message, "stuff started!!")
        expect(ResqueJob::Base.start_message).to eq("stuff started!!")
      end
    end

    context "class doens't have a @start_message variable" do
      it "should return a start message with job_type and queue" do
        if ResqueJob::Base.instance_variable_defined?(:@start_message)
          ResqueJob::Base.remove_instance_variable(:@start_message)
        end

        ResqueJob::Base.instance_variable_set(:@queue, :snake)
        allow(ResqueJob::Base).to receive_messages(job_type: "terrible job")
        expected_message = "Starting terrible job in queue 'snake'."
        expect(ResqueJob::Base.start_message).to eq(expected_message)
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
end
