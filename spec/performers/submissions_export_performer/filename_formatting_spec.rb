require "rails_spec_helper"

RSpec.describe SubmissionsExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::SubmissionsExport::SharedExamples
  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

  describe "student_directory_file_path" do
    let(:student_double) { double(:student) }
    let(:result) do
      performer.instance_eval do
        student_directory_file_path(@some_student, "whats_up.doc")
      end
    end

    before do
      performer.instance_variable_set(:@some_student, student_double)
      allow(performer).to receive(:student_directory_path) { "/this/great/path" }
    end

    it "gets the student directory path from the student" do
      expect(performer).to receive(:student_directory_path).with(student_double)
      result
    end

    it "builds the correct path relative to the student directory" do
      expect(result).to eq("/this/great/path/whats_up.doc")
    end
  end

  describe "#archive_root_dir" do
    let(:archive_root_dir_path) { Dir.mktmpdir }
    subject { performer.instance_eval { archive_root_dir }}
    before(:each) do
      performer.instance_variable_set(:@archive_root_dir, nil)
      allow(performer).to receive(:archive_root_dir_path) { archive_root_dir_path }
    end

    it "returns the archive root dir path" do
      expect(subject).to eq(archive_root_dir_path)
    end

    it "recursively builds the archive root dir path" do
      allow(FileUtils).to receive(:mkdir_p) {[archive_root_dir_path]}
      expect(FileUtils).to receive(:mkdir_p).with(archive_root_dir_path)
      subject
    end

    it "actually builds the archive root dir" do
      subject
      expect(Dir.exist?(archive_root_dir_path)).to be_truthy
    end

    it "caches the root dir path" do
      subject
      expect(FileUtils).not_to receive(:mkdir_p).with(archive_root_dir_path)
      subject
    end

    it "sets the root dir path to @archive_root_dir" do
      subject
      expect(performer.instance_variable_get(:@archive_root_dir)).to eq(archive_root_dir_path)
    end
  end

  describe "#archive_root_dir_path" do
    let(:tmp_dir) { Dir.mktmpdir }
    let(:expected_outcome) { File.expand_path(export_file_basename, tmp_dir) }
    let(:export_file_basename) { performer.submissions_export.export_file_basename }
    subject { performer.instance_eval { archive_root_dir_path }}

    before(:each) { allow(performer).to receive(:tmp_dir) { tmp_dir }}

    it "returns the archive root dir path" do
      expect(subject).to eq(expected_outcome)
    end

    it "caches the root dir path" do
      subject
      expect(File).not_to receive(:expand_path).with(export_file_basename, tmp_dir)
      subject
    end

    it "sets the root dir path to @archive_root_dir_path" do
      subject
      expect(performer.instance_variable_get(:@archive_root_dir_path)).to eq(expected_outcome)
    end
  end

  describe "tmp_dir" do
    subject { performer.instance_eval { tmp_dir }}
    it "builds a temporary directory" do
      expect(subject).to match(/\/(tmp|var\/folders)\/[\w\d-]+/) # match the tmp dir hash
    end

    it "caches the temporary directory" do
      original_tmp_dir = subject
      expect(subject).to eq(original_tmp_dir)
    end

    it "sets the directory path to @tmp_dir" do
      subject
      expect(performer.instance_variable_get(:@tmp_dir)).to eq(subject)
    end
  end

  describe "#ensure_s3fs_tmp_dir" do
    subject { performer.instance_eval { ensure_s3fs_tmp_dir } }
    let(:s3fs_tmp_dir_path) { Dir.mktmpdir }
    before(:each) { allow(performer).to receive(:s3fs_tmp_dir_path) { s3fs_tmp_dir_path } }

    context "s3fs_tmp_dir_path already exists" do
      it "doesn't build any new directories" do
        expect(FileUtils).not_to receive(:mkdir_p).with(s3fs_tmp_dir_path)
        subject
      end
    end

    context "s3fs_tmp_dir_path doesn't exist" do
      before { FileUtils.rmdir(s3fs_tmp_dir_path) }
      it "recursively builds the directories for tmp dir" do
        expect(FileUtils).to receive(:mkdir_p).with(s3fs_tmp_dir_path)
        subject
      end
    end
  end

  describe "tmp_dir_parent_path" do
    subject { performer.instance_eval { tmp_dir_parent_path } }
    let(:s3fs_tmp_dir_path) { Dir.mktmpdir }
    before(:each) { allow(performer).to receive(:s3fs_tmp_dir_path) { s3fs_tmp_dir_path } }

    context "system is using s3fs" do
      it "uses the s3fs parent path" do
        allow(performer).to receive(:use_s3fs?) { true }
        expect(subject).to eq(s3fs_tmp_dir_path)
      end
    end

    context "system is not using s3fs" do
      it "uses the system default tmp dir path" do
        allow(performer).to receive(:use_s3fs?) { false }
        expect(subject).to be_nil
      end
    end
  end

  describe "#s3fs_tmp_dir_path" do
    subject { performer.instance_eval { s3fs_tmp_dir_path } }
    it "uses a base path" do
      expect(subject).to match(/\/s3mnt\/tmp/)
    end

    it "includes the current environment name" do
      expect(subject).to match(Rails.env)
    end
  end

  describe "#use_s3fs?" do
    subject { performer.instance_eval { use_s3fs? } }
    let(:s3fs_tmp_dir_path) { Dir.mktmpdir }
    before(:each) { allow(performer).to receive(:s3fs_tmp_dir_path) { s3fs_tmp_dir_path } }

    context "staging environment" do
      before { allow(Rails).to receive(:env) { ActiveSupport::StringInquirer.new("staging") }}
      it "uses s3fs" do
        expect(subject).to be_truthy
      end
    end

    context "production environment" do
      before { allow(Rails).to receive(:env) { ActiveSupport::StringInquirer.new("production") }}
      it "uses s3fs" do
        expect(subject).to be_truthy
      end
    end

    context "development environment" do
      before { allow(Rails).to receive(:env) { ActiveSupport::StringInquirer.new("development") }}
      it "doesn't use s3fs" do
        expect(subject).to be_falsey
      end
    end
  end

  describe "archive_tmp_dir" do
    subject { performer.instance_eval { archive_tmp_dir }}

    it "builds a temporary directory for the archive" do
      expect(Dir).to receive(:mktmpdir).with(no_args)
      subject
    end

    it "caches the temporary directory" do
      original_tmp_dir = subject
      expect(subject).to eq(original_tmp_dir)
    end

    it "sets the directory path to @archive_tmp_dir" do
      subject
      expect(performer.instance_variable_get(:@archive_tmp_dir)).to eq(subject)
    end
  end

  describe "expanded_archive_base_path" do
    subject { performer.instance_eval { expanded_archive_base_path }}
    before do
      allow(performer).to receive(:export_file_basename) { "the_best_filename" }
      allow(performer).to receive(:archive_tmp_dir) { "/archive/tmp/dir" }
    end

    it "expands the export file basename from the archive tmp dir path" do
      expect(subject).to eq("/archive/tmp/dir/the_best_filename")
    end

    it "caches the basename" do
      subject
      expect(performer).not_to receive(:export_file_basename)
      subject
    end

    it "sets the expanded path to @expanded_archive_base_path" do
      subject
      expect(performer.instance_variable_get(:@expanded_archive_base_path)).to eq(subject)
    end
  end
end
