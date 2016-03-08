require "rails_spec_helper"

RSpec.describe S3Manager::Resource do
  subject { S3ResourceTest.new s3_object_key: s3_object_key }

  let(:s3_manager) { double(S3Manager::Manager).as_null_object }
  let(:s3_object_key) { "some-fake-key" }
  let(:temp_file) { Tempfile.new("some-file") }

  describe "#s3_manager" do
    let(:result) { subject.s3_manager }

    it "builds a new S3Manager::Manager object" do
      expect(S3Manager::Manager).to receive(:new)
      result
    end

    it "caches the object" do
      result
      expect(S3Manager::Manager).not_to receive(:new)
      result
    end

    it "sets the S3Manager object to @s3_manager" do
      allow(S3Manager::Manager).to receive(:new) { s3_manager }
      expect(result).to eq s3_manager
    end
  end

  describe "behaviors that don't define s3_manager" do
    before do
      allow(subject).to receive(:s3_manager) { s3_manager }
    end

    describe "#presigned_s3_url" do
      it "gets the presigned url for the s3 object" do
        expect(subject.s3_manager).to receive_message_chain(
          :bucket, :object, :presigned_url, :to_s)
        subject.presigned_s3_url
      end
    end


    describe "#upload_file_to_s3" do
      it "puts the encrypted object to s3" do
        expect(s3_manager).to receive(:put_encrypted_object)
          .with(s3_object_key, temp_file)
        subject.upload_file_to_s3(temp_file)
      end
    end

    #  def upload_file_to_s3(file_path)
    #    s3_manager.put_encrypted_object(s3_object_key, file_path)
    #  end

    #  def fetch_object_from_s3
    #    s3_manager.get_encrypted_object(s3_object_key)
    #  end

    #  def stream_s3_object_body
    #    s3_object = fetch_object_from_s3
    #    return unless s3_object and s3_object.body
    #    s3_object.body.read
    #  end

    #  def write_s3_object_to_file(target_file_path)
    #    s3_manager.write_encrypted_object_to_file(s3_object_key, target_file_path)
    #  end

    #  def delete_object_from_s3
    #    s3_manager.delete_object(s3_object_key)
    #  end

    describe "#s3_object_summary" do
      let(:result) { subject.s3_object_summary }

      before do
        allow(subject).to receive_messages(
          s3_object_key: s3_object_key, s3_manager: s3_manager
        )
      end

      it "builds a new object summary with the object key and the s3 manager" do
        expect(S3Manager::Manager::ObjectSummary).to receive(:new)
          .with(s3_object_key, s3_manager)
        result
      end

      it "returns an ObjectSummary object" do
        expect(result.class).to eq(S3Manager::Manager::ObjectSummary)
      end

      it "caches the new object summary" do
        result
        expect(S3Manager::Manager::ObjectSummary).not_to receive(:new)
        result
      end
    end
  end
end
