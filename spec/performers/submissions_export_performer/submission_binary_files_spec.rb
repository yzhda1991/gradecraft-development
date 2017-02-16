require "spec_helper"

RSpec.describe SubmissionsExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::SubmissionsExport::SharedExamples
  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

  describe "creating submission binary files" do
    let(:submissions) { [ submission_with_files, submission_without_files ] }
    let(:submission_with_files) { build(:submission, submission_files: submission_files, student: submitter) }
    let(:submission_without_files) { build(:submission, submission_files: []) }

    let(:submission_files) { [ submission_file1, submission_file2 ] }
    let(:submission_file1) { build(:submission_file, filename: "gary_ate_ants.ralph", file_missing: false) }
    let(:submission_file2) { build(:submission_file, file_missing: false) }

    let(:submitter) { build(:user, first_name: "Edwina", last_name: "Georgebot") }

    let(:tmp_dir) { Dir.mktmpdir }

    describe "create_submission_binary_files" do
      subject { performer.instance_eval { create_submission_binary_files } }
      before(:each) do
        performer.instance_variable_set(:@submissions, submissions)
      end

      describe "submission with files" do
        before { performer.instance_variable_set(:@submissions, [ submission_with_files ]) }
        it "creates a binary file for that submission" do
          expect(performer).to receive(:create_binary_files_for_submission).with(submission_with_files)
        end
      end

      describe "submission without files" do
        before { performer.instance_variable_set(:@submissions, [ submission_without_files ]) }
        it "doesn't create a binary file for that submission" do
          expect(performer).not_to receive(:create_binary_files_for_submission).with(submission_without_files)
        end
      end

      after(:each) { subject }
    end

    describe "create binary files for submission" do
      let(:result) do
        subject.create_binary_files_for_submission submission
      end
      let(:submission) { double(:submission).as_null_object }

      before do
        allow(submission).to receive_message_chain(:submission_files, :present)
          .and_return submission_files
      end

      describe "submission with files" do
        it "calls write_submission_binary_file for both submission files" do
          expect(performer).to receive(:write_submission_binary_file).twice
          result
        end
      end

      describe "submission without files" do
        let(:submission_files) { [] }

        it "doesn't write any binary files" do
          expect(performer).not_to receive(:write_submission_binary_file)
          result
        end
      end
    end

    describe "submission binary file name stuff" do
      describe "#submission_binary_file_path" do
        let(:result) do
          subject.submission_binary_file_path(submitter, submission_file1, 5)
        end

        before do
          allow(submission_file1).to receive(:instructor_filename)  { "ick.txt" }
          allow(subject).to receive(:submitter_directory_file_path)
            .with(submitter, "ick.txt").and_return "the/path"
        end

        it "builds the instructor filename for the submission file" do
          expect(submission_file1).to receive(:instructor_filename).with 5
          result
        end

        it "returns the submitter directory path for the submitter and filename" do
          expect(result).to eq "the/path"
        end
      end

      describe "#write_submission_binary_file" do
        let(:result) do
          subject.write_submission_binary_file(submitter, submission_file1, 5)
        end

        it "gets the binary submission file path" do
          expect(performer).to receive(:submission_binary_file_path)
            .with(submitter, submission_file1, 5)
          result
        end

        it "streams the s3 file to the disk via the submission file" do
          allow(performer).to receive(:submission_binary_file_path) { "/xyz" }
          expect(performer).to receive(:stream_s3_file_to_disk)
            .with(submission_file1, "/xyz")
          result
        end
      end

      describe "#stream_s3_file_to_disk" do
        subject { performer.instance_eval { stream_s3_file_to_disk(@some_submission_file, @some_target_file_path) }}
        let(:s3_manager) { performer.instance_eval { s3_manager }}
        let(:mikos_bases_file_path) { "#{tmp_dir}/allyoarbases_r_belong_2_miko.snk" }

        let(:cache_ivars) do
          performer.instance_variable_set(:@some_submission_file, submission_file1)
          performer.instance_variable_set(:@some_target_file_path, mikos_bases_file_path)
        end

        before(:each) do
          allow(submission_file1).to receive(:s3_object_file_key) { "something-weird-happened-here" }
          cache_ivars
        end

        context "s3_manager#write_s3_manager_to_disk succeeds without error" do
          before do
            allow(s3_manager).to receive(:write_s3_object_to_disk) { true }
          end

          it "writes the s3 file to the file path for the archive directory" do
            expect(s3_manager).to receive(:write_s3_object_to_disk).with(submission_file1.s3_object_file_key, mikos_bases_file_path)
            subject
          end
        end

        context "s3_manager#write_s3_object_to_disk raises an Aws NoSuchKey error" do
          it "marks the submission file as missing" do
            expect(submission_file1).to receive(:mark_file_missing)
            subject
          end
        end
      end

      describe "remove_if_exists" do
        let(:horses_path) { File.expand_path("horses.png", "spec/support/binary_files") }
        let(:final_horses_path) { File.expand_path("horses.png", tmp_dir) }
        let(:clean_up_horses) { File.delete final_horses_path if File.exist? final_horses_path }
        let(:copy_horses) { FileUtils.cp horses_path, final_horses_path }

        subject do
          performer.instance_eval do
            remove_if_exists( @some_horses_path )
          end
        end

        before { performer.instance_variable_set(:@some_horses_path, final_horses_path) }

        context "nothing exists at file_path" do
          before { clean_up_horses }

          it "shouldn't bother deleting anything" do
            expect(File).not_to receive(:delete).with(final_horses_path)
            subject
          end
        end

        context "something exists at file_path" do
          before(:each) { copy_horses }

          it "calls File.delete on file_path if something's there" do
            expect(File).to receive(:delete).with(final_horses_path)
            subject
          end

          it "actually deletes the file at file_path" do
            subject
            expect(File.exist?(final_horses_path)).to be_falsey
          end
        end
      end
    end
  end
end
