require 'rails_spec_helper'

class S3ManagerTest
  include S3Manager::Basics
end

include Toolkits::S3Manager::BasicsToolkit

RSpec.describe S3Manager::Basics do
  let(:s3_manager_test) { S3ManagerTest.new }

  describe "#s3_client" do
    subject { s3_manager_test.s3_client }

    it "builds a new S3 client" do
      expect(subject.class).to eq(Aws::S3::Client)
    end

    it "uses the correct env variables for the client" do
      expect(Aws::S3::Client).to receive(:new).with(s3_client_attributes)
      subject
    end

    it "caches the client" do
      subject
      expect(Aws::S3::Client).not_to receive(:new)
      subject
    end
  end

  describe "#s3_resource" do
    subject { s3_manager_test.s3_resource }

    it "builds a new S3 Resource object" do
      expect(subject.class).to eq(Aws::S3::Resource)
    end

    it "caches the resource" do
      subject
      expect(Aws::S3::Resource).not_to receive(:new)
      subject
    end
  end

  describe "#s3_bucket" do
    subject { s3_manager_test.s3_bucket }

    it "builds a new s3 client" do
      expect(s3_manager_test).to receive(:s3_client)
      subject
    end

    it "gets the s3 bucket from the resource" do
      expect(subject.class).to eq(Aws::S3::Bucket)
    end

    it "caches the bucket" do
      subject
      expect(s3_manager_test).not_to receive(:s3_resource)
      subject
    end
  end

  describe "#s3_bucket_name" do
    it "tells you the bucket name" do
    end
  end

  describe"#s3_object_attrs" do
    it "returns a hash of attributes for a new object" do
    end
  end
end
