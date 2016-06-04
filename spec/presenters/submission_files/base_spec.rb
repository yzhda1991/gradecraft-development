require "active_record_spec_helper"
require "./app/presenters/submission_files/base"

describe Presenters::SubmissionFiles::Base do
  subject { described_class.new }

  let(:submission_file) do
    double(:submission_file,
      submission: double(Submission),
      object_stream: double(S3Manager::ObjectStream).as_null_object,
      id: rand(1000)
    )
  end

  let(:params) do
    { submission_file_id: submission_file.id }
  end

  before do
    allow(subject).to receive(:params) { params }
    allow(subject).to receive(:submission_file) { submission_file }
  end

  describe "#submission_file" do
    let(:result) { subject.submission_file }

    context "params[:id] exists" do
      it "finds the submission file by id" do
        expect(SubmissionFile).to receive(:find).with submission_file.id
        result
      end

      it "caches the submission_file" do
        result
        expect(SubmissionFile).not_to receive(:find)
        result
      end

      it "sets an ivar for the submission_file" do
        result
        expect(subject.instance_variable_get(:@submission_file))
          .to eq submission_file
      end
    end

    context "params[:id] does not exist" do
      let(:params) do
        { submission_file_id: nil }
      end

      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end

  describe "#submission" do
    context "submission_file does not exist" do
      it "returns nil" do
        allow(subject).to receive(:submission_file) { nil }
        expect(subject.submission).to be_nil
      end
    end

    context "submission_file exists" do
      it "returns the submission from the submission_file" do
        expect(subject.submission).to eq submission_file.submission
      end
    end
  end

  describe "#submission_file_streamable?" do
    let(:result) { subject.submission_file_streamable? }

    context "submission_file does not exist" do
      it "returns false" do
        allow(subject).to receive(:submission_file) { nil }
        expect(result).to eq false
      end
    end

    context "submission_file exists" do
      it "returns the outcome of ObjectStream#exists?" do
        allow(submission_file).to receive_message_chain(
          :object_stream, :exists?) { "some-value" }
        expect(result).to eq "some-value"
      end
    end
  end

  describe "#stream_submission_file" do
    let(:result) { subject.stream_submission_file }

    context "the submission file is streamable" do
      it "streams the object from the submission file" do
        expect(submission_file.object_stream).to receive(:stream!)
        result
      end
    end

    context "the submission file is not streamable" do
      it "returns false" do
        allow(subject).to receive(:submission_file_streamable?) { false }
        expect(result).to eq false
      end
    end
  end

  describe "#filename" do
    let(:params) { { index: "10" } }
    it "returns the instructor_filename for the submission file" do
      expect(submission_file).to receive(:instructor_filename).with(10)
      subject.filename
    end
  end

  describe "#mark_submission_file_missing" do
    let(:result) { subject.mark_submission_file_missing }

    context "submission_file does not exist" do
      it "returns false" do
        allow(subject).to receive(:submission_file) { nil }
        expect(result).to eq false
      end
    end

    context "submission_file exists" do
      it "marks the submission_file missing" do
        expect(submission_file).to receive(:mark_file_missing)
        result
      end
    end
  end
end
