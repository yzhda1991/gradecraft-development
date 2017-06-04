include Toolkits::S3Manager::EncryptionToolkit

RSpec.describe S3Manager::Encryption do
  let(:s3_manager) { S3Manager::Manager.new }

  describe "#encrypted_client" do
    subject { s3_manager.encrypted_client }

    it "builds a new encrypted client" do
      expect(subject.class).to eq(Aws::S3::Encryption::Client)
    end

    it "uses a standard s3 client" do
      expect(subject.instance_variable_get(:@client)).to eq(s3_manager.client)
    end

    describe "cipher provider" do
      subject { s3_manager.encrypted_client.instance_variable_get(:@cipher_provider) }

      it "sets the kms_key_id" do
        expect(subject.instance_variable_get(:@kms_key_id)).to eq(s3_manager.kms_key_id)
      end

      it "sets the kms_client" do
        expect(subject.instance_variable_get(:@kms_client)).to eq(s3_manager.kms_client)
      end
    end

    it "caches the encrypted client" do
      subject
      expect(Aws::S3::Encryption::Client).not_to receive(:new)
      subject
    end
  end

  describe "managing client-encrypted objects" do
    let(:object_key) { "jerrys-hat" }
    let(:encrypted_client) { s3_manager.encrypted_client }
    let(:object_body) { File.new("jerry-was-here.doc", "w+b") }
    let(:put_encrypted_object) { s3_manager.put_encrypted_object(object_key, object_body) }
    after(:all) { FileUtils.rm("jerry-was-here.doc") if File.exist?("jerry-was-here.doc") }

    describe "#put_encrypted_object" do
      subject { put_encrypted_object }
      let(:file_path) { Tempfile.new("something-old").path }
      let(:put_encrypted_object) { s3_manager.put_encrypted_object(object_key, file_path) }

      it "should call #put_object on the encrypted client" do
        expect(s3_manager).to receive(:put_object_with_client).with(encrypted_client, object_key, file_path)
        subject
      end
    end
  end
end
