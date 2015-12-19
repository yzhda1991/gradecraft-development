require 'rails_spec_helper'

class S3ManagerTest
  include S3Manager::Basics
end

include Toolkits::S3Manager::BasicsToolkit

RSpec.describe S3Manager::Basics do
  describe "#s3_client" do
    subject { S3ManagerTest.new.s3_client }

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
end
