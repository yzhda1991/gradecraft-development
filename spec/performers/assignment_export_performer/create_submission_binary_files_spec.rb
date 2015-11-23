require 'rails_spec_helper'

RSpec.describe AssignmentExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::AssignmentExport::SharedExamples
  include ModelAddons::SharedExamples

  extend Toolkits::Performers::AssignmentExport::Context
  define_context

  subject { performer }

  describe "creating submission binary files" do
    let(:submissions) { [ submission_double1, submission_double2 ] }

    describe "create_submission_binary_files" do
      subject { performer.instance_eval { create_submission_binary_files }}
      before(:each) do
        performer.instance_variable_set(:@submissions, submissions)
      end

      describe "submission with files" do
        let(:submission_with_files) { double(:submission, submission_files: true) }

        before(:each) do
          submissions.each do |submission|
            allow(performer).to receive(:create_binary_files_for_submission).with(submission) { true }
          end
        end

        it "creates binary files for each submission" do
          submissions.each do |submission|
            expect(performer).to receive(:create_binary_files_for_submissions).with(submission) { true }
          end
          subject
        end
      end

      context "submissions don't have submission files" do
        let(:submission_double1) { double(:submission, submission_files: false) }
        let(:submission_double2) { double(:submission, submission_files: false) }

        before(:each) do
          submissions.each {|submission| allow(submission).to receive(:submission_files) { false }}
        end

        it "doesn't create binary files for each submission" do
          submissions.each do |submission|
            expect(performer).not_to receive(:create_binary_files_for_submissions).with(submission)
          end
          subject
        end
      end
    end

  end
end
