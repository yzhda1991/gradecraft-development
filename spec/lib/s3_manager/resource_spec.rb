require "active_record_spec_helper"
require "s3_manager/resource"
require "support/uni_mock/rails"
require_relative "../../support/test_classes/lib/s3_manager/s3_resource_test"

RSpec.describe S3Manager::Resource do
  subject { S3ResourceTest.new s3_object_key: s3_object_key }

  # add some helpers for stubbing the environment
  include UniMock::StubRails

  let(:s3_manager) { double(S3Manager::Manager).as_null_object }
  let(:s3_object_key) { "some-fake-key" }
  let(:temp_file) { Tempfile.new("some-file") }

  describe "callbacks" do
    subject { create(:submissions_export) }

    describe "rebuilding the s3 object key before save" do
      context "export_filename changed" do
        it "rebuilds the s3 object key" do
          expect(subject).to receive(:rebuild_s3_object_key)
          subject.update_attributes export_filename: "some_filename.txt"
        end
      end

      context "export_filename did not change" do
        it "doesn't rebuild the s3 object key" do
          expect(subject).not_to receive(:rebuild_s3_object_key)
          subject.update_attributes team_id: 5
        end
      end
    end
  end

  describe "#rebuild_s3_object_key" do
    before do
      allow(subject).to receive_messages(
        build_s3_object_key: "new-key",
        export_filename: "some_filename.txt"
      )
    end

    it "builds a new s3_object_key and caches it" do
      subject.rebuild_s3_object_key
      expect(subject.s3_object_key).to eq "new-key"
    end
  end

  describe "#build_s3_object_key" do
    subject { create(:submissions_export) }
    let(:result) { subject.build_s3_object_key("stuff.zip") }

    let(:expected_base_s3_key) do
      "exports/courses/40/assignments/50" \
      "/#{subject.created_at_date}" \
      "/#{subject.created_at_in_microseconds}/stuff.zip"
    end

    before do
      allow(subject).to receive_messages(course_id: 40, assignment_id: 50)
      stub_const "ENV", { "AWS_S3_DEVELOPER_TAG" => "jeff-moses" }
    end

    context "env is development" do
      before { stub_env "development" }

      it "prepends the developer tag to the store dirs and joins them" do
        expect(result).to eq ["jeff-moses", expected_base_s3_key].join("/")
      end
    end

    context "env is anything but development" do
      before { stub_env "sumpin-else" }

      it "joins the store dirs and doesn't use the developer tag" do
        expect(result).to eq expected_base_s3_key
      end
    end
  end

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

    describe "#upload_file_to_s3" do
      it "puts the encrypted object to s3" do
        expect(s3_manager).to receive(:put_encrypted_object)
          .with(s3_object_key, temp_file)
        subject.upload_file_to_s3(temp_file)
      end
    end

    describe "#fetch_object_from_s3" do
      it "fetches the encrypted object from s3" do
        expect(s3_manager).to receive(:get_encrypted_object)
          .with(s3_object_key)
        subject.fetch_object_from_s3
      end
    end

    describe "#stream_s3_object_body" do
      let(:result) { subject.stream_s3_object_body }
      it "fetches the encrypted object from s3" do
        expect(s3_manager).to receive(:get_encrypted_object).with(s3_object_key)
        result
      end

      context "s3_object doesn't exist" do
        it "returns nil" do
          allow(subject).to receive(:fetch_object_from_s3) { nil }
          expect(result).to be_nil
        end
      end

      context "s3_object exists" do
        let(:s3_object) { double(:s3_object).as_null_object }

        before do
          allow(subject).to receive(:fetch_object_from_s3) { s3_object }
        end

        context "s3_object has no body" do
          it "returns nil" do
            allow(s3_object).to receive(:body) { nil }
            expect(result).to be_nil
          end
        end

        context "s3_object has a body" do
          it "streams the object body via #read" do
            allow(s3_object).to receive_message_chain(:body, :read) { "a-body" }
            expect(result).to eq("a-body")
          end
        end
      end
    end

    describe "#write_s3_object_to_file" do
      it "writes the encrypted object to a local file" do
        expect(s3_manager).to receive(:write_encrypted_object_to_file)
          .with(s3_object_key, temp_file)
        subject.write_s3_object_to_file(temp_file)
      end
    end

    describe "#delete_object_from_s3" do
      it "deletees the encrypted object from s3" do
        expect(s3_manager).to receive(:delete_object).with(s3_object_key)
        subject.delete_object_from_s3
      end
    end

    describe "#s3_object_exists?" do
      it "checks whether the s3_object_exists?" do
        expect(subject).to receive_message_chain(:s3_object_summary, :exists?)
        subject.s3_object_exists?
      end
    end

    describe "#s3_object_summary" do
      let(:result) { subject.s3_object_summary }

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

    describe "#presigned_s3_url" do
      it "gets the presigned url for the s3 object" do
        expect(subject.s3_manager).to receive_message_chain(
          :bucket, :object, :presigned_url, :to_s)
        subject.presigned_s3_url
      end
    end
  end
end
