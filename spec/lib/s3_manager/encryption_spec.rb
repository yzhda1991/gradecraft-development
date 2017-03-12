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

    describe "#get_encrypted_object" do
      subject { s3_manager.get_encrypted_object(object_key) }
      before { put_encrypted_object }
      let(:get_object_attrs) do
        { bucket: s3_manager.bucket_name, key: object_key }
      end

      it "should call #get_object on the encrypted client" do
        expect(encrypted_client).to receive(:get_object)
        subject
      end

      it "should get an AWS Seahorse object in response" do
        expect(subject.class).to eq(Seahorse::Client::Response)
      end

      it "should have been sucessful" do
        expect(subject.successful?).to be_truthy
      end

      it "should have the correct body of the gotten object" do
        expect(encrypted_client).to receive(:get_object).with(get_object_attrs)
        subject
      end

      it "should suggest that AES256 encryption was used" do
        expect(subject.server_side_encryption).to eq("AES256")
      end
    end
  end
end
