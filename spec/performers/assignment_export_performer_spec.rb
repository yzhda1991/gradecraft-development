require 'rails_spec_helper'

RSpec.describe AssignmentExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::AssignmentExport::SharedExamples
  include ModelAddons::SharedExamples

  extend Toolkits::Performers::AssignmentExport::Context
  define_context

  subject { performer }

  it_behaves_like "ModelAddons::ImprovedLogging is included"

  describe "attributes" do
    let(:default_attributes) {{
      assignment_id: assignment.id,
      course_id: course.id,
      professor_id: professor.id,
      student_ids: students.collect(&:id),
      team_id: nil
    }}
    before(:each) { performer.instance_variable_set(:@students, students) }

    context "team is not present" do
      it "doesn't have a team_id" do
        expect(performer.attributes).to eq(default_attributes)
      end
    end

    context "team is present" do
      let(:performer) { performer_with_team }
      it "has a team_id" do
        expect(performer.attributes).to eq(default_attributes.merge(team_id: team.id))
      end
    end
  end

  # private and protected methods
  
  describe "sorted_student_directory_keys" do
    let(:contrived_student_submissions_hash) {{ "dave_hoggworthy_40"=>"", "carla_makeshift_10"=>"", "bordwell_hamhock_25"=>"" }}
    let(:expected_keys_result) { %w[ bordwell_hamhock_25  carla_makeshift_10  dave_hoggworthy_40 ] }

    before do
      allow(performer).to receive(:submissions_grouped_by_student) { contrived_student_submissions_hash }
    end

    it "sorts the keys alphabetically" do
      expect(performer.instance_eval { sorted_student_directory_keys }).to eq(expected_keys_result)
    end
  end

  describe "export_file_basename" do
    subject { performer.instance_eval { export_file_basename }}

    before(:each) do
      allow(performer).to receive(:archive_basename) { "some_great_assignment" }
      allow(Time).to receive(:now) { Date.parse("Jan 20 1995") }
    end

    it "includes the fileized_assignment_name" do
      expect(subject).to match(/^some_great_assignment/)
    end

    it "is appended with a YYYY-MM-DD formatted timestamp" do
      expect(subject).to match(/1995-01-20$/)
    end

    it "caches the filename" do
      subject
      expect(performer).not_to receive(:archive_basename)
      subject
    end

    it "sets the filename to an @export_file_basename" do
      subject
      expect(performer.instance_variable_get(:@export_file_basename)).to eq("some_great_assignment_export_1995-01-20")
    end
  end

  describe "generate_export_csv" do
    subject { performer.instance_eval { generate_export_csv }}
    let(:csv_path) { performer.instance_eval { csv_file_path }}

    before(:each) do
      performer.instance_variable_set(:@assignment, assignment)
      allow(assignment).to receive(:grade_import) { CSV.generate {|csv| csv << ["dogs", "are", "nice"]} }
    end

    it "saves the result of assignment#grade_import" do
      subject
      expect(CSV.read(csv_path).first).to eq(["dogs", "are", "nice"])
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
        expect(subject).to eq("blog_entry_5_the_walloping_wildebeest")
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
      allow(performer).to receive(:sanitize_filename) { "this is a jocular output" } 
      expect(performer).to receive(:sanitize_filename).with("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
      subject
    end

    it "truncates the final string to twenty five characters" do
      expect(subject).to eq("abcdefghijklmnopqrstuvwxy")  
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

  describe "team_present?" do
    context "team_id was included in the initialized performer attributes" do
      subject { performer.instance_eval { team_present? }}
      it { should be_falsey }
    end

    context "team_id was not included in the initialized performer attributes" do
      subject { performer_with_team.instance_eval { team_present? }}
      it { should be_truthy }
    end
  end

  describe "export_csv_successful?" do
    subject { performer.instance_eval { export_csv_successful? }}
    let(:tmp_dir) { Dir.mktmpdir }
    let(:test_file_path) { File.expand_path("csv_test.txt", tmp_dir) }

    context "the csv was successfully created" do
      before do
        File.open(test_file_path, 'w') {|f| f.write("test file") }
        allow(performer).to receive(:csv_file_path) { test_file_path }
      end

      it "returns true" do
        expect(subject).to be_truthy
      end

      it "sets an @export_csv_successful ivar" do
        subject
        expect(performer.instance_variable_get(:@export_csv_successful)).to be_truthy
      end

      it "caches the value" do
        subject # call it once to cache it
        expect(File).to_not receive(:exist?).with("csv_test.txt")
        subject # shouldn't check again after caching
      end

      after do
        File.delete(test_file_path) if File.exist?(test_file_path)
      end
    end

    context "the csv was not created" do
      let(:false_file_path) { File.expand_path("false_test.txt", tmp_dir) }

      before do
        allow(performer).to receive(:csv_file_path) { "false_test.txt" }
      end

      it "returns false" do
        expect(subject).to be_falsey
      end

      it "doesn't cache the value" do
        expect(performer.instance_variable_get(:@export_csv_successful)).to eq(nil)
      end

      after do
        File.delete(false_file_path) if File.exist?(false_file_path)
      end
    end

  end
  
  describe "csv_file_path" do
    subject { performer.instance_eval { csv_file_path }}
    it "uses the grade import template" do
      expect(subject).to match(/grade_import_template\.csv$/)
    end

    it "expands the path off of tmp_dir" do
      allow(performer).to receive(:tmp_dir) { "/some/weird/path/" }
      expect(subject).to match(/^\/some\/weird\/path\//)
    end

    it "caches the file path" do
      cached_call = subject
      expect(subject).to eq(cached_call)
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

  describe "archive_tmp_dir" do
    subject { performer.instance_eval { archive_tmp_dir }}
    it "builds a temporary directory for the archive" do
      expect(subject).to match(/\/tmp\/[\w\d-]+/) # match the tmp dir hash
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
  
  describe "work_resources_present?" do
    let(:assignment_present) { performer.instance_variable_set(:@assignment, true) }
    let(:assignment_not_present) { performer.instance_variable_set(:@assignment, false) }
    let(:students_present) { performer.instance_variable_set(:@students, true) }
    let(:students_not_present) { performer.instance_variable_set(:@students, false) }

    subject { performer.instance_eval { work_resources_present? }}

    context "both @assignment and @students are present" do
      before { assignment_present; students_present }
      it { should be_truthy }
    end

    context "@assignment is present but @students are not" do
      before { assignment_present; students_not_present }
      it { should be_falsey }
    end

    context "@students is present but @assignment is not" do
      before { students_present; assignment_not_present }
      it { should be_falsey }
    end

    context "neither @students nor @assignment are present" do
      before { students_not_present; assignment_not_present }
      it { should be_falsey }
    end
  end

  describe "submissions_by_student" do
    let(:student1) { create(:user, first_name: "Ben", last_name: "Bailey") }
    let(:student2) { create(:user, first_name: "Mike", last_name: "McCaffrey") }
    let(:student3) { create(:user, first_name: "Dana", last_name: "Dafferty") }

    let(:submission1) { double(:submission, id: 1, student: student1) }
    let(:submission2) { double(:submission, id: 2, student: student2) }
    let(:submission3) { double(:submission, id: 3, student: student3) }
    let(:submission4) { double(:submission, id: 4, student: student2) } # note that this uses student 2

    let(:grouped_submission_expectation) {{
      "bailey_ben-#{student1.id}" => [submission1],
      "mccaffrey_mike-#{student2.id}" => [submission2, submission4],
      "dafferty_dana-#{student3.id}" => [submission3]
    }}

    let(:submissions_by_id) { [submission1, submission2, submission3, submission4].sort_by(&:id) }

    before(:each) do
      performer.instance_variable_set(:@submissions, submissions_by_id)
    end

    subject do
      performer.instance_eval { submissions_grouped_by_student }
    end

    it "should reorder the @submissions array by student" do
      expect(subject).to eq(grouped_submission_expectation)
    end

    it "should use 'last_name_first_name-id' for the hash keys" do
      expect(subject.keys.first).to eq("bailey_ben-#{student1.id}")
    end

    it "should return an array of submissions for each student" do
      expect(subject["mccaffrey_mike-#{student2.id}"]).to eq([submission2, submission4])
    end
  end
end
