require 'rails_spec_helper'

include Toolkits::S3Manager::EncryptionToolkit

RSpec.describe S3Manager::ObjectSummary do
  let(:s3_manager) { S3Manager::Manager.new }
  let(:object_summary) { S3Manager::Manager::ObjectSummary.new("waffles", s3_manager) }

  describe "an ObjectSummary instance" do
    subject { object_summary }

    describe "#initialize" do
      it "sets the object key" do
        expect(subject.instance_variable_get(:@object_key)).to eq("waffles")
      end

      it "sets the s3_manager" do
        expect(subject.instance_variable_get(:@s3_manager)).to eq(s3_manager)
      end
    end

    describe "readers" do
      it "can read the object_key" do
        expect(object_summary.object_key).to eq("waffles")
      end

      it "can read the s3_manager" do
        expect(object_summary.s3_manager).to eq(s3_manager)
      end
    end
  end

  describe "#summary_client" do
    subject { object_summary.summary_client }

    it "creates a new ObjectSummary client from the attributes" do
      expect(Aws::S3::ObjectSummary).to receive(:new).with(object_summary.summary_client_attributes)
      subject
    end

    it "returns an Aws::S3::ObjectSummary instance" do
      expect(subject.class).to eq(Aws::S3::ObjectSummary)
    end

    it "caches the summary client" do
      subject
      expect(Aws::S3::ObjectSummary).not_to receive(:new)
      subject
    end
  end

  describe "#summary_client_attributes" do
    subject { object_summary.summary_client_attributes }

    it "contains the bucket_name" do
      expect(subject[:bucket_name]).to eq(s3_manager.bucket_name)
    end

    it "contains the key for the target object" do
      expect(subject[:key]).to eq(object_summary.object_key)
    end

    it "contains the AWS client from the s3_manager" do
      expect(subject[:client]).to eq(object_summary.s3_manager.client)
    end
  end

  describe "summary client wrapper methods" do
    subject { object_summary.summary_client }
    let(:aws_waiter) { Aws::Waiters::Waiter.new(delay: 0.1, max_attempts: 1) }

    describe "#exists?" do
      it "calls #exists? on the summary client" do
        expect(subject).to receive(:exists?)
        object_summary.exists?
      end
    end

    describe "#wait_until_exists" do
      it "calls #wait_until_exists on the summary client" do
        expect(subject).to receive(:wait_until_exists)
        object_summary.wait_until_exists {|aws_waiter|}
      end
    end

    describe "#wait_until_not_exists" do
      it "calls #wait_until_not_exists on the summary client" do
        expect(subject).to receive(:wait_until_not_exists)
        object_summary.wait_until_not_exists {|aws_waiter|}
      end
    end
  end
end
