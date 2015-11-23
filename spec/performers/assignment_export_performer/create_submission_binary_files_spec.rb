require 'rails_spec_helper'

RSpec.describe AssignmentExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::AssignmentExport::SharedExamples
  include ModelAddons::SharedExamples

  extend Toolkits::Performers::AssignmentExport::Context
  define_context

  subject { performer }

  describe "creating submission binary files" do
    let(:submissions) { [ submission_with_files, submission_without_files ] }
    let(:submission_with_files) { double(:submission, submission_files: true) }
    let(:submission_without_files) { double(:submission, submission_files: false) }

    describe "create_submission_binary_files" do
      subject { performer.instance_eval { create_submission_binary_files } }
      before { performer.instance_variable_set(:@submissions, submissions) }

      describe "submission with files" do
        it "creates a binary file for that submission" do
          expect(performer).to receive(:create_binary_files_for_submission).with(submission_with_files)
          subject
        end
      end

      describe "submission without files" do
        it "doesn't create a binary file for that submission" do
          expect(performer).not_to receive(:create_binary_files_for_submission).with(submission_without_files)
          subject
        end
      end
    end

  end
end
