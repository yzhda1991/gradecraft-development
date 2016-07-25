require "rails_spec_helper"

RSpec.describe SubmissionsExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::SubmissionsExport::SharedExamples
  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

  describe "#filename_time" do
    subject { performer.instance_eval { filename_time }}
    let(:course) { create(:course, time_zone: "Bogota") }

    before(:each) do
      performer.instance_variable_set(:@filename_time, nil)
      performer.instance_variable_set(:@course, course)
    end

    it "sets the timezone from the @course" do
      subject
      expect(Time.zone.name).to eq("Bogota")
    end

    it "gets the time now" do
      expect(Time).to receive_message_chain(:zone, :now)
      subject
    end

    describe "returning the actual time" do
      let(:some_time) { Date.parse("Feb 20 1835").to_time }
      before { allow(Time).to receive_message_chain(:zone, :now) { some_time } }

      it "should return the proper time" do
        subject
        expect(performer.instance_variable_get(:@filename_time)).to eq(some_time)
      end
    end
  end

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

  describe "archive_basename" do
    let(:result) { subject.archive_basename }

    before do
      allow(subject).to receive_messages(
        formatted_assignment_name: "The Assignment",
        formatted_team_name: "The Team"
      )
    end

    it "combines the formatted assignment and team names" do
      expect(result).to eq "The Assignment - The Team"
    end

    context "Team name is nil" do
      it "compacts out the team name" do
        allow(subject).to receive(:formatted_team_name) { nil }
        expect(result).to eq "The Assignment"
      end
    end
  end

  describe "#formatted_team_name" do
    let(:result) { subject.formatted_team_name }

    # make sure that stale instance variables don't interfere with caching
    before(:each) { subject.instance_variable_set(:@team_name, nil) }

    context "team_present? is false and @team_name is nil" do
      before do
        allow(subject).to receive(:team_present?) { false }
      end

      it "returns nil" do
        expect(result).to be_nil
      end

      it "doesn't set a @team_name" do
        result
        expect(subject.instance_variable_get(:@team_name)).to be_nil
      end
    end

    context "team_present? is true" do
      before do
        allow(subject).to receive(:team_present?) { true }
        allow(subject).to receive_message_chain(:team, :name) { "Super Team" }
      end

      it "titleizes the team name" do
        expect(Formatter::Filename).to receive(:titleize).with "Super Team"
        result
      end

      it "sets a @team_name" do
        result
        expect(subject.instance_variable_get(:@team_name)).to eq "Super Team"
      end

      it "caches the team name" do
        result
        expect(Formatter::Filename).not_to receive(:titleize)
        result
      end
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
    let(:expected_outcome) { File.expand_path(export_base_filename, tmp_dir) }
    let(:export_base_filename) { performer.instance_eval { export_file_basename }}
    subject { performer.instance_eval { archive_root_dir_path }}

    before(:each) { allow(performer).to receive(:tmp_dir) { tmp_dir }}

    it "returns the archive root dir path" do
      expect(subject).to eq(expected_outcome)
    end

    it "caches the root dir path" do
      subject
      expect(File).not_to receive(:expand_path).with(export_base_filename, tmp_dir)
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
