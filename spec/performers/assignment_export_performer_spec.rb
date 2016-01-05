require 'rails_spec_helper'

RSpec.describe AssignmentExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::AssignmentExport::SharedExamples
  include ModelAddons::SharedExamples

  extend Toolkits::Performers::AssignmentExport::Context
  define_context

  subject { performer }

  it_behaves_like "ModelAddons::ImprovedLogging is included"

#   {
#     student_ids: @students.collect(&:id),
#     submissions_snapshot: submissions_snapshot,
#     export_filename: "#{export_file_basename}.zip",
#     last_export_started_at: Time.now
#   }

  describe "#assignment_export_attributes" do
    before do
      allow(performer).to receive_messages({
        submissions_snapshot: {some: "hash"},
        export_file_basename: "really_bad_file"
      })
    end

    subject { performer.assignment_export_attributes }
    let(:export_start_time) { Date.parse("Jan 20 1987").to_time }

    it "should include the student ids" do
      expect(subject[:student_ids]).to eq(performer.instance_variable_get(:@students).collect(&:id))
    end

    it "should include the last export started time" do
      allow(Time).to receive(:now) { export_start_time }
      expect(subject[:last_export_started_at]).to eq(export_start_time)
    end

    it "should include the submissions snapshot" do
      expect(subject[:submissions_snapshot]).to eq({some: "hash"})
    end

    it "should include the export filename" do
      expect(subject[:export_filename]).to eq("really_bad_file.zip")
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

  describe "s3 concerns" do
    before do
      performer.instance_variable_set(:@assignment_export, assignment_export)
      allow(performer).to receive(:expanded_archive_base_path) { "/this/weird/path" }
    end
    
    describe "#upload_archive_to_s3" do
      subject { performer.instance_eval { upload_archive_to_s3 }}

      it "calls #upload_file_to_s3 on the assignment export with the file path" do
        expect(assignment_export).to receive(:upload_file_to_s3).with("/this/weird/path.zip")
        subject
      end
    end

    describe "check_s3_upload_success" do
      subject { performer.instance_eval { check_s3_upload_success }}

      it "checks if the object exists on S3 through the assignment export" do
        expect(assignment_export).to receive(:s3_object_exists?)
        subject
      end
    end
  end
end
