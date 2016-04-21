require "active_record_spec_helper"
require_relative "../../app/presenters/submission_files_presenter"

describe SubmissionFilesPresenter do
  subject { described_class.new }

  let(:submission_file) { SubmissionFile.last }
  let(:params) do
    { id: submission_file.id }
  end

  before do
    create(:submission_file)
    allow(subject).to receive(:params) { params }
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
        { id: nil }
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

  describe "#object_streamable?" do
    context "submission_file does not exist" do
    end
  end

  describe "#stream_object" do
    it "streams the object from the submission file" do
    end
  end

  describe "#filename" do
    it "returns the instructor_filename for the submission file" do
    end
  end

  describe "#mark_submission_file_missing" do
    context "submission_file does not exist" do
      it "returns false" do
      end
    end

    context "submission_file exists" do
      it "marks the submission_file missing" do
      end
    end
  end
end
