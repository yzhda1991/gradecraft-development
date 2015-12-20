require 'rails_spec_helper'

RSpec.describe AssignmentExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::AssignmentExport::SharedExamples
  include ModelAddons::SharedExamples

  extend Toolkits::Performers::AssignmentExport::Context
  define_context

  subject { performer }

  describe "do_the_work" do
    after(:each) { subject.do_the_work }

    context "work resources are present" do
      before do
        allow(subject).to receive(:work_resources_present?) { true }
      end

      it "requires success" do
        expect(subject).to receive(:require_success).exactly(10).times
      end

      it "adds outcomes to subject.outcomes" do
        expect { subject.do_the_work }.to change { subject.outcomes.size }.by(10)
      end

      it "fetches the csv data" do
        allow(subject).to receive(:generate_export_csv).and_return "some,csv,data"
        expect(subject).to receive(:generate_export_csv)
      end

      it "checks whether the exported csv was successfully saved on disk" do
        expect(subject).to receive(:export_csv_successful?)
      end

      it "creates directories for each student" do
        expect(subject).to receive(:create_student_directories)
      end

      it "ensures that all student directories were created successfully" do
        expect(subject).to receive(:student_directories_created_successfully?)
      end

      it "creates submission text files in each student directory where needed" do
        expect(subject).to receive(:create_submission_text_files)
      end

      it "creates submission binary files in each student directory where present" do
        expect(subject).to receive(:create_submission_binary_files)
      end
    end

    context "work resources are not present" do
      before do
        allow(subject).to receive(:work_resources_present?) { false }
      end

      after(:each) { subject.do_the_work }

      it "doesn't require success" do
        expect(subject).not_to receive(:require_success)
      end

      it "doesn't add outcomes to subject.outcomes" do
        expect { subject.do_the_work }.not_to change { subject.outcomes.size }
      end

      it "doesn't fetch the csv data" do
        allow(subject).to receive(:generate_export_csv).and_return "some,csv,data"
        expect(subject).not_to receive(:generate_export_csv)
      end
    end
  end
end
