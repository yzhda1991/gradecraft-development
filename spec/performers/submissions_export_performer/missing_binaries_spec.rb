require "rails_spec_helper"

RSpec.describe "SubmissionsExportPerformer missing binary file handling" do
  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  describe "#missing_binaries_file_path" do
    subject { performer.instance_eval { missing_binaries_file_path }}
    let(:archive_root_dir) { Dir.mktmpdir }
    before { allow(performer).to receive(:archive_root_dir) { archive_root_dir } }

    it "returns the file path for the missing files text" do
      expect(File).to receive(:expand_path).with("missing_files.txt", archive_root_dir)
      subject
    end

    it "builds a file path for the submission file" do
      expect(subject).to eq("#{archive_root_dir}/missing_files.txt")
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

  describe "#write_note_for_missing_binary_files" do
    subject { performer.instance_eval { write_note_for_missing_binary_files }}
    let(:archive_root_dir) { Dir.mktmpdir }
    let(:missing_binaries_file_path) { "#{archive_root_dir}/missing_files.txt" }
    let(:file_lines) { File.open(missing_binaries_file_path, "rt").readlines }

    before(:each) do
      allow(performer).to receive(:archive_root_dir) { archive_root_dir }
    end

    describe "intro line" do
      let(:students) { create_list(:user, 1) }
      before { allow(performer).to receive(:students_with_missing_binaries) { students }}

      it "adds a message to the missing files text file" do
        subject
        expect(file_lines.first).to match(/The following files were uploaded/)
      end
    end

    describe "printing students with missing files" do
      let(:students) { create_list(:user, 2) }
      before { allow(performer).to receive(:students_with_missing_binaries) { students }}

      it "prints a line for each student with a missing file" do
        subject
        expect(file_lines).to include(students.first.name + ":\n")
        expect(file_lines).to include(students.last.name + ":\n")
      end
    end

    describe "printing submission file names for each student" do
      let(:students) { create_list(:user, 2) }
      let(:submission_file_with_student) { create(:submission_file, filename: "stuff_rly.txt", submission: submission_with_student) }
      let(:submission_with_student) { create(:submission, student: students.first) }
      let(:submission_file_without_student) { create(:submission_file, filename: "srsly.txt") }
      let(:submission_files) { [ submission_file_with_student, submission_file_without_student ] }

      before do
        allow(performer).to receive(:students_with_missing_binaries) { students }
        allow(performer).to receive(:submission_files_with_missing_binaries) { submission_files }
      end

      context "missing file student id matches the id of the current student" do
        it "prints the name of the current file" do
          subject
          expect(file_lines).to include(submission_file_with_student.filename + "\n")
        end
      end

      context "missing file student id doesn't match the id of a current student" do
        it "doesn't print the name of the current file" do
          subject
          expect(file_lines).not_to include(submission_file_without_student.filename + "\n")
        end
      end

    end
  end
end
