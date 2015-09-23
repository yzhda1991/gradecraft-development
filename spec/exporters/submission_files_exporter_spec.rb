require 'spec_helper'

RSpec.describe SubmissionFilesExporter, type: :exporter do
  let(:stubbed_submission) { @stubbed_submission || submission_double }
  let(:exporter) do
    SubmissionFilesExporter.new(stubbed_submission)
  end
  
  # public methods
  describe "directory_files" do
    context "has comment or link?" do
      it "should return an array of hashes for all submissions and text files in the directory" do
        stub_exporter_with_text_file_values
        expect(exporter.directory_files).to eq(
          [ serialized_text_file_expectation ] + serialized_submission_files_expectation
        )
      end
    end

    context "submission has comment or link but no submission files" do
      it "should return an array with only the serialized text file" do
        @stubbed_submission = submission_double_with_nils(:submission_files)
        stub_exporter_with_text_file_values
        expect(exporter.directory_files).to eq( [ serialized_text_file_expectation ] )
      end
    end

    context "submission has submission files but no text comment or link" do
      it "should return an array with only the submission files" do
        @stubbed_submission = submission_double_with_nils(:link, :text_comment)
        stub_exporter_with_text_file_values
        expect(exporter.directory_files).to eq( serialized_submission_files_expectation )
      end
    end

    context "submission doesn't have a comment or link, and doesn't have any submission files" do
      it "should return an empty array" do
        @stubbed_submission = submission_double_with_nils(:link, :text_comment, :submission_files)
        stub_exporter_with_text_file_values
        expect(exporter.directory_files).to eq( [] )
      end
    end
  end

  subject { SubmissionFilesExporter.new(submission_double) }

  # private methods
  describe "formatted_text_filename" do
    it "should downcase all characters in the filename and remove duplicate underscores" do
      expect(subject.instance_eval { formatted_text_filename }).to eq(
        "haight_anne_this_name_is_long_fo_submission_content.txt"
      )
    end
  end

  describe "base_text_filename" do
    it "should render the unformatted filename for the text file" do
      expect(subject.instance_eval { base_text_filename }).to eq(
        "Haight_Anne_This_name_is_long_fo__submission_content.txt",
      )
    end
  end

  describe "assignment_name_snippet" do
    it "it should replace spaces with underscores and take a 20-character slice of the assignment name" do
      expect(subject.instance_eval { assignment_name_snippet }).to eq(
        "This_name_is_long_fo_"
      )
    end
  end

  describe "serialized_submission_files" do
    it "should create a hash for each submission file" do
      expect(subject.instance_eval { serialized_submission_files }).to eq(
        serialized_submission_files_expectation
      )
    end
  end

  describe "serialized_text_file" do
    it "should create a hash for each submission file" do
      stub_text_file_values_for(subject)
      expect(subject.instance_eval { serialized_text_file }).to eq(
        serialized_text_file_expectation
      )
    end
  end

  describe "text_file_content" do
    it "should create a string from the title, comment, and link" do
      allow(subject).to receive_messages(
        text_content_title: "a good title",
        text_comment: "a great text comment",
        submission_link: "the best submission link"
      )
      expect(subject.instance_eval { text_file_content }).to eq(
        "a good title\na great text comment\nthe best submission link"
      )
    end
  end

  private

  def stub_text_file_values_for(entity)
    allow(entity).to receive(:text_file_content).and_return("some content!!")
    allow(entity).to receive(:formatted_text_filename).and_return("some filename!!")
    entity
  end

  def serialized_text_file_expectation
    { content: "some content!!", filename: "some filename!!", content_type: "text" }
  end

  def stub_exporter_with_text_file_values
    allow(exporter).to receive_messages(text_file_content: "some content!!", formatted_text_filename: "some filename!!")
  end

  def serialized_submission_files_expectation
    submission_file_doubles.collect do |submission_file|
      { path: submission_file.url, content_type: submission_file.content_type }
    end
  end

  def submission_double
    double(:submission,
      link: "http://batman.com",
      text_comment: "Greezus!",
      submission_files: submission_file_doubles,
      student: student_double,
      assignment: assignment_double
    )
  end

  def submission_double_with_nils(*nil_attrs)
    this_double = nil_attrs.inject(submission_double) do |memo, nil_attr|
      allow(memo).to receive(nil_attr).and_return(nil)
      memo
    end
    stub_text_file_values_for(this_double)
  end

  def student_double
    double(:student,
      first_name: "Anne",
      last_name: "Haight"
    )
  end

  def submission_file_doubles
    [
      double(:submission_file,
        url: "http://s3.com/abcde",
        content_type: "text/pdf"),
      double(:submission_file,
        url: "http://s3.com/edcba",
        content_type: "text/doc")
    ]
  end

  def assignment_double
    double(:assignment, name: "This name is long fo!!20hitshere!!r a good reason")
  end
end
