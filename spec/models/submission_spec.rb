require 'spec_helper'

describe Submission do

  before do
    @submission = build(:submission)
  end

  subject { @submission }

  it { is_expected.to respond_to("assignment_id")}
  it { is_expected.to respond_to("student_id")}
  it { is_expected.to respond_to("feedback")}
  it { is_expected.to respond_to("comment")}
  it { is_expected.to respond_to("created_at")}
  it { is_expected.to respond_to("updated_at")}
  it { is_expected.to respond_to("attachment_file_name")}
  it { is_expected.to respond_to("attachment_content_type")}
  it { is_expected.to respond_to("attachment_file_size")}
  it { is_expected.to respond_to("attachment_updated_at")}
  it { is_expected.to respond_to("link")}
  it { is_expected.to respond_to("text_feedback")}
  it { is_expected.to respond_to("text_comment")}
  it { is_expected.to respond_to("creator_id")}
  it { is_expected.to respond_to("group_id")}
  it { is_expected.to respond_to("graded")}
  it { is_expected.to respond_to("released_at")}
  it { is_expected.to respond_to("task_id")}
  it { is_expected.to respond_to("course_id")}
  it { is_expected.to respond_to("assignment_type_id")}
  it { is_expected.to respond_to("assignment_type")}

  it { is_expected.to be_valid }

  describe "when a source url is invalid" do
    before { @submission.link = "not a url" }
    it { is_expected.not_to be_valid }
  end

  it "can't be saved without any information" do
    @submission.link = nil
    @submission.text_comment = nil
    expect { @submission.save! }.to raise_error(ActiveRecord::RecordNotSaved)
  end

  it "can be saved with only a text comment" do
    @submission.text_comment = "I volunteer! I volunteer! I volunteer as tribute!"
    @submission.save!
    expect expect(@submission.errors.size).to eq(0)
  end

  it "can be saved with only a link" do
    @submission.link = "http://www.amazon.com/dp/0439023521"
    @submission.save!
    expect expect(@submission.errors.size).to eq(0)
  end

  it "can be saved with only an attached file" do
    @submission.submission_files.new(filename: "test", filepath: "polsci101/submissionfile/", file: fixture_file('test_image.jpg', 'img/jpg'))
    @submission.save!
    expect expect(@submission.errors.size).to eq(0)
  end

  it "can have an an attached file, comment, and link" do
    @submission.text_comment = "I volunteer! I volunteer! I volunteer as tribute!"
    @submission.link = "http://www.amazon.com/dp/0439023521"
    @submission.submission_files.new(filename: "test", filepath: "polsci101/submissionfile/", file: fixture_file('test_image.jpg', 'img/jpg'))
    @submission.save!
    expect expect(@submission.errors.size).to eq(0)
  end
end
