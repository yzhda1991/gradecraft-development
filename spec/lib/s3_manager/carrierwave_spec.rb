RSpec.describe S3Manager::Carrierwave do
  subject { submission_file }

  let(:submission_file) { build(:submission_file) }
  let(:s3_manager) { S3Manager::Manager.new }
  let(:source_object) { Tempfile.new("walter-srsly") }
  let(:s3_object_key) { "lets-see-what-happens.txt" }
  let(:object_exists?) { submission_file.exists_on_s3? }
  let(:put_object_to_s3) { s3_manager.put_object(s3_object_key, source_object) }

  describe "inclusion of S3Manager::Basics" do
    it "responds to S3Manager::Basics methods" do
      expect(subject).to respond_to(:object_attrs)
      expect(subject).to respond_to(:bucket_name)
    end
  end

  describe "#url" do
    subject(:each) { submission_file.url }

    let(:presigned_url) { double(:presigned_url).as_null_object }
    let(:s3_object) { double(:s3_object).as_null_object }

    before(:each) do
      allow(submission_file).to receive_message_chain(:file, :url)
        .and_return "great url, bro"
      allow(submission_file).to receive(:filepath) { "sumpin'" }
      allow(submission_file).to receive(:s3_object) { s3_object }
      allow(s3_object).to receive(:presigned_url) { presigned_url }
    end

    it "gets the presigned url for the s3 object" do
      expect(s3_object).to receive(:presigned_url).with(:get, expires_in: 900)
    end

    it "converts all of that into a string" do
      expect(presigned_url).to receive(:to_s)
    end

    after(:each) { subject }
  end

  describe "#s3_object" do
    subject(:each) { submission_file.s3_object }

    let(:bucket) { double(:bucket).as_null_object }
    let(:object) { double(:object).as_null_object }
    let(:s3_object_file_key) { "hopefully-this-never-happens" }

    before(:each) do
      allow(submission_file).to receive(:bucket) { bucket }
      allow(bucket).to receive(:object) { object }
      allow(submission_file).to receive_messages(
        bucket: bucket,
        s3_object_file_key: s3_object_file_key
      )
    end

    it "fetches the bucket object with the s3_object_file_key" do
      expect(bucket).to receive(:object).with(s3_object_file_key)
    end

    after(:each) { subject }
  end

  describe "#s3_object_file_key" do
    subject { submission_file.s3_object_file_key }
    let(:tempfile) { Tempfile.new("walter") }

    context "cached_file_path is present" do
      before do
        submission_file.update_attributes store_dir: "great_dir"

        allow(submission_file).to receive_messages(
          mounted_filename: "stuff.txt",
          cached_file_path: "/some/great/path.png"
        )
      end

      it "returns the cached file path" do
        expect(subject).to eq "/some/great/path.png"
      end
    end

    context "filepath is present" do
      before do
        allow(submission_file).to receive_messages(
          filepath: tempfile,
          filepath_includes_filename?: true
        )
      end

      it "returns the CGI-unescaped filepath" do
        expect(CGI).to receive(:unescape).with(tempfile)
        subject
      end
    end

    context "filepath is not present" do
      before do
        allow(submission_file).to receive(:filepath) { nil }
        allow(submission_file).to receive_message_chain(:file, :path)
          .and_return "/stuff/path"
      end

      it "returns the #path from the file" do
        expect(subject).to eq("/stuff/path")
      end
    end
  end

  describe "#mounted_filename" do
    subject(:result) { mounted_submission_file.mounted_filename }

    let(:mounted_submission_file) do
      create(:submission_file, filepath: "this-is-great.txt")
    end

    before do
      allow(mounted_submission_file)
        .to receive_message_chain(:file, :mounted_as).and_return :filepath
    end

    it "returns the value for the #mounted_as attribute" do
      expect(result).to eq("this-is-great.txt")
    end
  end

  describe "filepath_includes_filename?" do
    subject(:result) { submission_file.filepath_includes_filename? }
    context "filepath is present and filepath includes/matches the filename" do
      before do
        allow(submission_file).to receive_messages(
          filepath: "some/path/to/nowhere.txt",
          filename: "nowhere.txt"
        )
      end

      it "returns true" do
        expect(result).to be_truthy
      end
    end

    context "filepath is not present" do
      before do
        allow(submission_file).to receive(:filepath) { nil }
      end

      it "returns false" do
        expect(subject).to be_falsey
      end
    end

    context "filepath is present but doesn't match the filename" do
      before do
        allow(submission_file).to receive_messages(
          filepath: "some/path/to/nowhere.txt",
          filename: "everglades.pdf"
        )
      end

      it "returns false" do
        expect(subject).to be_falsey
      end
    end
  end

  describe "#cached_file_path" do
    subject { submission_file.cached_file_path }

    before(:each) do
      submission_file[:store_dir] = "great_dir"

      allow(submission_file).to receive(:mounted_filename) { "stuff.txt" }
    end

    context "both store_dir and filename exist" do
      it "joins the store_dir and the filename with a forward slash" do
        expect(subject).to eq "great_dir/stuff.txt"
      end

      it "caches the joined cached_file_path value" do
        first_call = subject
        expect(first_call.object_id).to eq(subject.object_id)
      end
    end
  end

  describe "caching the #store_dir" do
    let(:store_dir) { Dir.mktmpdir }
    let(:cache_store_dir) { submission_file.instance_eval { cache_store_dir } }

    describe "#cache_store_dir" do
      before do
        allow(submission_file).to receive(:file)
          .and_return double(:file, store_dir: store_dir)
      end

      it "caches the store_dir attribute" do
        cache_store_dir
        expect(submission_file[:store_dir]).to eq(store_dir)
      end
    end

    describe "caching the store_dir before create" do
      before do
        allow_any_instance_of(AttachmentUploader)
          .to receive(:store_dir).and_return store_dir
        # cache the submission file after the
        submission_file
        cache_store_dir
      end

      it "caches the store_dir before create" do
        expect(submission_file[:store_dir]).to eq(store_dir)
      end
    end

    after(:each) do
      FileUtils.rm_rf(store_dir, secure: true)
    end
  end

  describe "#delete_from_s3" do
    subject { submission_file.delete_from_s3 }

    let(:bucket) { double(:bucket).as_null_object }
    let(:object) { double(:object).as_null_object }
    let(:s3_object_file_key) { "hopefully-this-never-happens" }

    before(:each) do
      allow(submission_file).to receive_messages(
        bucket: bucket,
        s3_object_file_key: s3_object_file_key
      )
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
