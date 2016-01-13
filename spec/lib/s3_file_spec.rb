require 'rails_spec_helper'

# a cylon looks exactly the same, but is not the same.
# the whole point of the cylon is to include the S3File.
class S3FileCylon
  include S3File
end

RSpec.describe "An S3File inheritor" do
  let(:s3_file_cylon) { S3FileCylon.new }
  subject { s3_file_cylon }

  describe "inclusion of S3Manager::Basics" do
    it "responds to S3Manager::Basics methods" do
      expect(subject).to respond_to(:object_attrs)
      expect(subject).to respond_to(:bucket_name)
    end
  end

  describe "#url" do
    subject { s3_file_cylon.url }
    before do
      allow(s3_file_cylon).to receive_message_chain(:file, :url) { "great url, bro" }
    end

    context "Rails env is development" do
      before { allow(Rails).to receive_message_chain(:env, :development?) { true }}
      it "returns the url of the file" do
        expect(subject).to eq("great url, bro")
        subject
      end
    end

    context "Rails env is anything but development" do
      let(:bucket) { double(:bucket).as_null_object }
      let(:object) { double(:object).as_null_object }
      let(:presigned_url) { double(:presigned_url).as_null_object }
      let(:s3_object_file_key) { "hopefully-this-never-happens" }

      before(:each) do
        allow(Rails).to receive_message_chain(:env, :development?) { false }
        allow(s3_file_cylon).to receive_messages({
          bucket: bucket,
          s3_object_file_key: s3_object_file_key
        })
        allow(bucket).to receive(:object) { object }
        allow(object).to receive(:presigned_url) { presigned_url }
      end

      it "fetches the bucket object with the s3_object_file_key" do
        expect(bucket).to receive(:object).with(s3_object_file_key)
      end

      it "gets the presigned url for the object" do
        expect(object).to receive(:presigned_url).with(:get, expires_in: 900)
      end

      it "converts all of that into a string" do
        expect(presigned_url).to receive(:to_s)
      end

      after(:each) { subject }
    end
  end

  describe "#s3_object_file_key" do
    let(:tempfile) { Tempfile.new('walter') }
    subject { s3_file_cylon.s3_object_file_key }

    context "filepath is present" do
      before { allow(s3_file_cylon).to receive(:filepath) { tempfile }}

      it "returns the CGI-unescaped filepath" do
        expect(CGI).to receive(:unescape).with(tempfile)
        subject
      end
    end

    context "filepath is not present" do
      before do
        allow(s3_file_cylon).to receive(:filepath) { nil }
        allow(s3_file_cylon).to receive_message_chain(:file, :path) { "/stuff/path" }
      end

      it "returns the #path from the file" do
        expect(subject).to eq("/stuff/path")
      end
    end
  end

  describe "#remove" do
    subject { s3_file_cylon.remove }

    let(:bucket) { double(:bucket).as_null_object }
    let(:object) { double(:object).as_null_object }
    let(:s3_object_file_key) { "hopefully-this-never-happens" }

    before(:each) do
      allow(s3_file_cylon).to receive_messages({
        bucket: bucket,
        s3_object_file_key: s3_object_file_key
      })
      allow(bucket).to receive(:object) { object }
    end

    it "fetches the bucket object with the s3_object_file_key" do
      expect(bucket).to receive(:object).with(s3_object_file_key)
    end

    it "gets the presigned url for the object" do
      expect(object).to receive(:delete)
    end

    after(:each) { subject }
  end
end
