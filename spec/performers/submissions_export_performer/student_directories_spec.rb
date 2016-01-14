require 'rails_spec_helper'

RSpec.describe SubmissionsExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::SubmissionsExport::SharedExamples
  include ModelAddons::SharedExamples

  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

  describe "student directories" do
    let(:tmp_dir_path) { Dir.mktmpdir }
    let(:students) { [ student1, student2 ] }
    let(:stub_students) { performer.instance_variable_set(:@students, students) }
    let(:student1) { create(:user, first_name: "Anna", last_name: "Stevens") }
    let(:student2) { create(:user, first_name: "Tina", last_name: "Rogers") }
    let(:student_directory_names) {{ student1.id => "stevens_anna", student2.id => "rogers_tina" }}
    let(:student_dir_path1) { "#{tmp_dir_path}/stevens_anna" }
    let(:student_dir_path2) { "#{tmp_dir_path}/rogers_tina" }
    let(:student_dir_paths) { [ student_dir_path1, student_dir_path2 ] }
    let(:remove_student_dirs) do
      [ student_dir_path1, student_dir_path2 ].each do |dir_path|
        Dir.rmdir(dir_path) if Dir.exist?(dir_path)
      end
    end

    before(:each) do
      allow(performer).to receive(:tmp_dir) { tmp_dir_path }
      allow(performer).to receive(:student_directory_names) { student_directory_names }
    end

    describe "missing_student_directories" do
      subject { performer.instance_eval { missing_student_directories }}
      before(:each) { stub_students }

      context "student directories are missing" do
        it "returns the names of the missing directories relative to the tmp_dir" do
          expect(subject).to eq(["stevens_anna", "rogers_tina"])
        end
      end

      context "student directories have been created" do
        it "returns an empty array" do
          performer.instance_eval { create_student_directories }
          expect(subject).to be_empty
        end
        after { remove_student_dirs }
      end
    end

    describe "student_directories_created_successfully?" do
      subject { performer.instance_eval { student_directories_created_successfully? }}

      context "missing_student_directories is empty" do
        it "returns true" do
          allow(performer).to receive(:missing_student_directories) { [] }
          expect(subject).to be_truthy
        end
      end

      context "missing_student_directories are present" do
        it "returns false" do
          allow(performer).to receive(:missing_student_directories) { ["stevens_anna", "rogers_tina"] }
          expect(subject).to be_falsey
        end
      end
    end

    describe "create_student_directories" do
      subject { performer.instance_eval { create_student_directories }}
      before(:each) { stub_students }

      it "calls Dir.mkdir once for each student in @students" do
        expect(Dir).to receive(:mkdir).with(student_dir_path1).once
        expect(Dir).to receive(:mkdir).with(student_dir_path2).once
        subject
      end

      it "creates the directories for each student" do
        student_dir_paths.each {|dir_path| expect(Dir).to receive(:mkdir).with(dir_path) }
        subject
      end

      it "actually creates the directories on disk for each student" do
        subject
        student_dir_paths.each {|dir_path| expect(Dir.exist?(dir_path)).to be_truthy }
      end

      after(:each) do
        remove_student_dirs
      end
    end

    describe "student_directory_path" do
      subject { performer.instance_eval { student_directory_path( @some_student ) }}
      before do
        performer.instance_variable_set(:@some_student, student1)
      end

      it "returns the correct directory path" do
        expect(subject).to eq("#{tmp_dir_path}/#{student_directory_names[student1.id]}")
      end

      it "expands the path relative to the tmp_dir" do
        expect(File).to receive(:expand_path).with(student_directory_names[student1.id], tmp_dir_path)
        subject
      end
    end
  end
end
