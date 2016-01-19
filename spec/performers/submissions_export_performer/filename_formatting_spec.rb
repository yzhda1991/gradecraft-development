require 'rails_spec_helper'

RSpec.describe SubmissionsExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::SubmissionsExport::SharedExamples
  include ModelAddons::SharedExamples

  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

  describe "export_file_basename" do
    subject { performer.instance_eval { export_file_basename }}
    let(:filename_timestamp) { "2020-10-15 - 12:30:20pm" }

    before(:each) do
      performer.instance_variable_set(:@export_file_basename, nil)
      allow(performer).to receive(:archive_basename) { "some_great_submissions" }
      allow(performer).to receive(:filename_timestamp) { filename_timestamp }
    end

    it "includes the fileized_assignment_name" do
      expect(subject).to match(/^some_great_submissions/)
    end

    it "is appended with a YYYY-MM-DD formatted timestamp" do
      expect(subject).to match(/2020-10-15/)
    end

    it "caches the filename" do
      subject
      expect(performer).not_to receive(:archive_basename)
      subject
    end

    it "sets the filename to an @export_file_basename" do
      subject
      expect(performer.instance_variable_get(:@export_file_basename)).to eq("some_great_submissions - #{filename_timestamp}")
    end
  end

  describe "#filename_timestamp" do
    subject { performer.instance_eval { filename_timestamp }}
    let(:filename_time) { Date.parse("Jan 20 1995").to_time }
    before do
      allow(performer).to receive(:filename_time) { filename_time }
    end

    it "formats the filename time" do
      expect(subject).to match(filename_time.strftime("%Y-%m-%d - %I:%M:%S%P"))
    end
  end

  describe "#filename_time" do
    subject { performer.instance_eval { filename_time }}
    let(:time_now) { Date.parse("Jan 20 1995").to_time }
    before do
      allow(Time).to receive(:now) { time_now }
    end

    it "caches the time" do
      subject
      expect(Time).not_to receive(:now)
      subject
    end

    it "gets the time now" do
      expect(Time).to receive(:now) { time_now }
      subject
    end
  end

  describe "student_directory_file_path" do
    let(:student_double) { double(:student) }
    subject { performer.instance_eval { student_directory_file_path(@some_student, "whats_up.doc") }}
    before do
      performer.instance_variable_set(:@some_student, student_double)
      allow(performer).to receive(:student_directory_path) { "/this/great/path" }
    end

    it "gets the student directory path from the student" do
      expect(performer).to receive(:student_directory_path).with(student_double)
      subject
    end

    it "builds the correct path relative to the student directory" do
      expect(subject).to eq("/this/great/path/whats_up.doc")
    end
  end

  describe "archive_basename" do
    subject { performer.instance_eval { archive_basename }}
    before(:each) do
      allow(performer).to receive(:formatted_assignment_name) { "blog_entry_5" }
      allow(performer).to receive(:formatted_team_name) { "the_walloping_wildebeest" }
    end

    context "team_present? is true" do
      before { allow(performer).to receive(:team_present?) { true }}
      it "combines the formatted assignment and team names" do
        expect(subject).to eq("blog_entry_5 - the_walloping_wildebeest")
      end
    end

    context "team_present? is false" do
      before { allow(performer).to receive(:team_present?) { false }}
      it "returns only the formatted assignment name" do
        expect(subject).to eq("blog_entry_5")
      end
    end
  end
  
  describe "formatted_assignment_name" do
    subject { performer.instance_eval { formatted_assignment_name }}

    it "passes the assignment name into the formatter" do
      expect(performer).to receive(:formatted_filename_fragment).with(assignment.name)
      subject
    end
  end
  
  describe "formatted_team_name" do
    subject { performer_with_team.instance_eval { formatted_team_name }}

    it "passes the team name into the formatter" do
      expect(performer_with_team).to receive(:formatted_filename_fragment).with(team.name)
      subject
    end
  end

  describe "formatted_filename_fragment" do
    subject { performer.instance_eval { formatted_filename_fragment("ABCDEFGHIJKLMNOPQRSTUVWXYZ") }}

    it "sanitizes the fragment" do
      allow(performer).to receive(:titleize_filename) { "this is a jocular output" } 
      expect(performer).to receive(:titleize_filename).with("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
      subject
    end

    it "doesn't truncate the final string" do
      expect(subject).to eq("Abcdefghijklmnopqrstuvwxyz")  
    end
  end

  describe "titleize_filename" do
    it "titleizes everything" do
      expect(performer.instance_eval { titleize_filename("THISISSUPERCAPPY") }).to \
        eq("Thisissupercappy")
    end

    it "substitutes consecutive non-word characters with spaces" do
      expect(performer.instance_eval { titleize_filename("whoa\\ gEORG  !!! IS ...dead") }).to \
        eq("Whoa Georg Is Dead")
    end

    it "removes leading spaces" do
      expect(performer.instance_eval { titleize_filename("          garrett_rules") }).to \
        eq("Garrett Rules")  
    end

    it "removes trailing spaces" do
      expect(performer.instance_eval { titleize_filename("garrett_sucks        ") }).to \
        eq("Garrett Sucks")  
    end
  end

  describe "sanitize_filename" do
    it "downcases everything" do
      expect(performer.instance_eval { sanitize_filename("THISISSUPERCAPPY") }).to \
        eq("thisissupercappy")
    end

    it "substitutes consecutive non-word characters with underscores" do
      expect(performer.instance_eval { sanitize_filename("whoa\\ gEORG  !!! IS ...dead") }).to \
        eq("whoa_georg_is_dead")
    end

    it "removes leading underscores" do
      expect(performer.instance_eval { sanitize_filename("____________garrett_rules") }).to \
        eq("garrett_rules")  
    end

    it "removes trailing underscores" do
      expect(performer.instance_eval { sanitize_filename("garrett_sucks__________") }).to \
        eq("garrett_sucks")  
    end
  end

  describe "#archive_root_dir", focus: true do
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

  describe "#archive_root_dir_path", focus: true do
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
      expect(subject).to match(/\/tmp\/[\w\d-]+/) # match the tmp dir hash
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
