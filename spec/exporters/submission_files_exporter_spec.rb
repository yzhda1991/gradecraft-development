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
        "Haight_Anne_This_name_is_long_fo__submission_content.txt"
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
      stub_text_file_content_values
      expect(subject.instance_eval { text_file_content }).to eq(
        "a good title\na great text comment\nthe best submission link"
      )
    end
  end

  describe "text_content_title" do
    it "should generate a title with the student name" do
      expect(subject.instance_eval { text_content_title }).to eq(
        "Submission items from Haight, Anne\n"
      )
    end
  end

  describe "text_comment" do
    context "submission has a text comment" do
      it "should return a string with the text comment" do
        allow(subject).to receive_message_chain(:submission, :text_comment) { "Hobos everywhere!!" }
        expect(subject.instance_eval { text_comment }).to eq(
          "\ntext comment: Hobos everywhere!!\n"
        )
      end
    end

    context "submission has no text comment" do
      it "should return nil" do
        allow(subject).to receive_message_chain(:submission, :text_comment) { nil }
        expect(subject.instance_eval { text_comment }).to be_nil
      end
    end
  end

  describe "submission_link" do
    context "submission has a link" do
      it "should return a string with the link" do
        allow(subject).to receive_message_chain(:submission, :link) { "http://fark.com" }
        expect(subject.instance_eval { submission_link }).to eq(
          "\nlink: http://fark.com\n"
        )
      end
    end

    context "submission has no text comment" do
      it "should return nil" do
        allow(subject).to receive_message_chain(:submission, :link) { nil }
        expect(subject.instance_eval { submission_link }).to be_nil
      end
    end
  end

  describe "has_comment_or_link?" do
    context "submission has a text comment and a link" do
      it "should be true" do
        stub_submission_for_has_comment_or_link?(text_comment: true, link: true)
        expect(subject.instance_eval { has_comment_or_link? }).to be_truthy
      end
    end

    context "submission has a text comment but no link" do
      it "should be true" do
        stub_submission_for_has_comment_or_link?(text_comment: true, link: false)
        expect(subject.instance_eval { has_comment_or_link? }).to be_truthy
      end
    end

    context "submission has a link but no text comment" do
      it "should be true" do
        stub_submission_for_has_comment_or_link?(text_comment: false, link: true)
        expect(subject.instance_eval { has_comment_or_link? }).to be_truthy
      end
    end

    context "submission has neither a text comment nor a link" do
      it "should be false" do
        stub_submission_for_has_comment_or_link?(text_comment: false, link: false)
        expect(subject.instance_eval { has_comment_or_link? }).to be_falsey
      end
    end
  end

  describe "initialization" do
    subject { SubmissionFilesExporter.new(@submission_double || submission_double) }

    before(:each) do
      @submission_double = submission_double
    end

    it "should set @files to an empty array" do
      expect(subject.instance_variable_get("@files")).to eq([])
    end

    it "should assign the submission argument to @submission" do
      expect(subject.instance_variable_get("@submission")).to eq(@submission_double)
    end

    it "should assign the submission's assignment to @assignment" do
      @assignment_double = assignment_double
      allow(@submission_double).to receive_messages(assignment: @assignment_double)
      expect(subject.instance_variable_get("@assignment")).to eq(@assignment_double)
    end

    it "should assign the submission's student to @student" do
      @student_double = student_double
      allow(@submission_double).to receive_messages(student: @student_double)
      expect(subject.instance_variable_get("@student")).to eq(@student_double)
    end
  end

  describe "attr_reader" do
    describe "files" do
      it "should return @files" do
        @files_double = files_double
        subject.instance_variable_set("@files", @files_double)
        expect(subject.files).to eq(@files_double)
      end
    end

    describe "submission" do
      it "should return @submission" do
        @submission_double = submission_double
        subject.instance_variable_set("@submission", @submission_double)
        expect(subject.submission).to eq(@submission_double)
      end
    end

    describe "assignment" do
      it "should return @assignment" do
        @assignment_double = assignment_double
        subject.instance_variable_set("@assignment", @assignment_double)
        expect(subject.assignment).to eq(@assignment_double)
      end
    end

    describe "student" do
      it "should read @student" do
        @student_double = student_double
        subject.instance_variable_set("@student", @student_double)
        expect(subject.student).to eq(@student_double)
      end
    end
  end

  private

  def stub_submission_for_has_comment_or_link?(attrs={})
    attrs.each do |attr, value|
      allow(subject).to receive_message_chain(:submission, attr, :present?) { value }
    end
  end

  def stub_text_file_content_values
    allow(subject).to receive_messages(
      text_content_title: "a good title",
      text_comment: "a great text comment",
      submission_link: "the best submission link"
    )
  end

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
      assignment: assignment_double)
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
           last_name: "Haight")
  end

  def files_double
    double(:files)
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
