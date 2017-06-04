include Toolkits::S3Manager::BasicsToolkit

RSpec.describe S3Manager::Manager do
  let(:s3_manager) { S3Manager::Manager.new }

  describe "#client" do
    subject { s3_manager.client }

    it "builds a new S3 client" do
      expect(subject.class).to eq(Aws::S3::Client)
    end

    it "uses the correct env variables for the client" do
      expect(Aws::S3::Client).to receive(:new).with(client_attributes)
      subject
    end

    it "caches the client" do
      subject
      expect(Aws::S3::Client).not_to receive(:new)
      subject
    end
  end

  describe "#resource" do
    subject { s3_manager.resource }

    it "builds a new S3 Resource object" do
      expect(subject.class).to eq(Aws::S3::Resource)
    end

    it "caches the resource" do
      subject
      expect(Aws::S3::Resource).not_to receive(:new)
      subject
    end
  end

  describe "#bucket" do
    subject { s3_manager.bucket }

    it "builds a new s3 client" do
      expect(s3_manager).to receive(:client)
      subject
    end

    it "gets the s3 bucket from the resource" do
      expect(subject.class).to eq(Aws::S3::Bucket)
    end

    it "caches the bucket" do
      subject
      expect(s3_manager).not_to receive(:resource)
      subject
    end
  end

  describe "#bucket_name" do
    before do
      ENV["AWS_S3_BUCKET"] = "some-bucket-name"
    end

    it "should use the bucketname from AWS_S3_BUCKET" do
      expect(s3_manager.bucket_name).to eq("some-bucket-name")
    end

    after do
      ENV["AWS_S3_BUCKET"] = "gradecraft-test"
    end
  end

  describe"#object_attrs" do
    it "returns a hash of attributes for a new object" do
      allow(s3_manager).to receive(:bucket_name) { "walrus-bucket" }
      expect(s3_manager.object_attrs).to eq({ bucket: "walrus-bucket" })
    end
  end

  describe "object management" do
    let(:s3_manager) { S3Manager::Manager.new }
    let(:client) { s3_manager.client }
    let(:filename) { "unencrypted-jerry-was-here.doc" }
    let(:object_key) { "jerrys-unencrypted-hat" }
    let(:object_body) { File.new(filename, "w+b") }
    let(:put_object) { s3_manager.put_object(object_key, object_body) }
    let(:delete_jerry) { FileUtils.rm(filename) if File.exist?(filename) }

    before(:each) { client }

    describe "#put_object" do
      let(:file_path) { Tempfile.new("something-old").path }
      let(:put_object) { s3_manager.put_object(object_key, file_path) }
      subject { put_object }

      it "should call #put_object on the encrypted client" do
        expect(s3_manager).to receive(:put_object_with_client).with(client, object_key, file_path)
        subject
      end
    end
  end
end
