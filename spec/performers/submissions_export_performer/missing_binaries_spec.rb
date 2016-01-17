require 'rails_spec_helper'

RSpec.describe "SubmissionsExportPerformer missing binary file handling" do
  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  describe "#missing_binaries_file_path" do
    subject { performer.instance_eval { missing_binaries_file_path }}
    let(:tmp_dir) { Dir.mktmpdir }
    before { allow(performer).to receive(:tmp_dir) { tmp_dir } }

    it "returns the file path for the missing files text" do
      expect(File).to receive(:expand_path).with("missing_files.txt", tmp_dir)
      subject
    end

    it "builds a file path for the submission file" do
      expect(subject).to eq("#{tmp_dir}/missing_files.txt")
    end
  end

  describe "#submission_files_with_missing_binaries" do
    subject { performer.instance_eval { submission_files_with_missing_binaries }}
    let(:assignment) { create(:assignment) }
    let(:submission_files) { create_list(:submission_file, 2) }
    before(:each) do
      performer.instance_variable_set(:@assignment, assignment)
      allow(assignment).to receive(:submission_files_with_missing_binaries) { submission_files }
    end

    it "gets the submission files with missing binaries from the assignment" do
      expect(assignment).to receive(:submission_files_with_missing_binaries)
      subject
    end

    describe "caching" do
      it "caches the result" do
        subject
        expect(assignment).not_to receive(:submission_files_with_missing_binaries)
        subject
      end

      it "sets an instance variable" do
        subject
        expect(performer.instance_variable_get(:@submission_files_with_missing_binaries)).to eq(submission_files)
      end
    end
  end

  describe "#students_with_missing_binaries" do
    subject { performer.instance_eval { students_with_missing_binaries }}
    let(:assignment) { create(:assignment) }
    let(:submission_files) { create_list(:submission_file, 2) }
    before(:each) do
      performer.instance_variable_set(:@assignment, assignment)
      allow(assignment).to receive(:students_with_missing_binaries) { submission_files }
    end

    it "gets the submission files with missing binaries from the assignment" do
      expect(assignment).to receive(:students_with_missing_binaries)
      subject
    end

    describe "caching" do
      it "caches the result" do
        subject
        expect(assignment).not_to receive(:students_with_missing_binaries)
        subject
      end

      it "sets an instance variable" do
        subject
        expect(performer.instance_variable_get(:@students_with_missing_binaries)).to eq(submission_files)
      end
    end
  end
end
