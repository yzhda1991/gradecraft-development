require 'spec_helper'

describe SubmissionFile do

  before do
    @submission = build(:submission)
    @submission_file = @submission.submission_files.new(filename: "test", file: fixture_file('test_image.jpg', 'img/jpg'))
  end

  subject { @submission_file }

  it { is_expected.to respond_to("filename")}
  it { is_expected.to respond_to("submission_id")}
  it { is_expected.to respond_to("filepath")}
  it { is_expected.to respond_to("file")}

  it { is_expected.to be_valid }

  describe "when filename is not present" do
    before { @submission_file.filename = nil }
    it { is_expected.not_to be_valid }
  end

  describe "as a dependency of the submission" do
    it "is saved when the parent submission is saved" do
      @submission.save!
      expect(@submission_file.submission_id).to equal @submission.id
      expect(@submission_file.new_record?).to be_falsey
    end

    it "is deleted when the parent submission is destroyed" do
      @submission.save!
      expect {@submission.destroy}.to change(SubmissionFile, :count).by(-1)
    end
  end

  it "accepts text files as well as images" do
    @submission_file.file = fixture_file('test_file.txt', 'txt')
    @submission.save!
    expect expect(@submission_file.url).to match(/.*\/uploads\/submission_file\/file\/#{@submission_file.id}\/\d+_test_file\.txt/)
  end

  it "accepts multiple files" do
    @submission.submission_files.new(filename: "test", filepath: 'uploads/submission_file/', file: fixture_file('test_file.txt', 'img/jpg'))
    @submission.save!
    expect(@submission.submission_files.count).to equal 2
  end

  it "has an accessible url" do
    @submission.save!
    expect expect(@submission_file.url).to match(/.*\/uploads\/submission_file\/file\/#{@submission_file.id}\/\d+_test_image\.jpg/)
  end

  it "shortens and removes non-word characters from file names on save" do
    @submission_file.file = fixture_file('Too long, strange characters, and Spaces (In) Name.jpg', 'img/jpg')
    @submission.save!
    expect expect(@submission_file.url).to match(/.*\/uploads\/submission_file\/file\/#{@submission_file.id}\/\d+_too_long__strange_characters__and_spaces_\.jpg/)
  end
end
