require "active_record_spec_helper"

describe Submission do
  subject { build(:submission) }

  describe "validations" do
    it { is_expected.to be_valid }

    it "requires a valid url" do
      subject.link = "not a url"
      expect(subject).to_not be_valid
      expect(subject.errors[:link]).to include "is invalid"
    end
  end

  it "can't be saved without any information" do
    subject.link = nil
    subject.text_comment = nil
    expect { subject.save! }.to raise_error(ActiveRecord::RecordNotSaved)
  end

  it "can be saved with only a text comment" do
    subject.text_comment = "I volunteer! I volunteer! I volunteer as tribute!"
    subject.save!
    expect(subject.errors.size).to eq(0)
  end

  it "can be saved with only a link" do
    subject.link = "http://www.amazon.com/dp/0439023521"
    subject.save!
    expect expect(subject.errors.size).to eq(0)
  end

  it "can be saved with only an attached file" do
    subject.submission_files.new(filename: "test", filepath: "polsci101/submissionfile/", file: fixture_file('test_image.jpg', 'img/jpg'))
    subject.save!
    expect expect(subject.errors.size).to eq(0)
  end

  it "can have an an attached file, comment, and link" do
    subject.text_comment = "I volunteer! I volunteer! I volunteer as tribute!"
    subject.link = "http://www.amazon.com/dp/0439023521"
    subject.submission_files.new(filename: "test", filepath: "polsci101/submissionfile/", file: fixture_file('test_image.jpg', 'img/jpg'))
    subject.save!
    expect expect(subject.errors.size).to eq(0)
  end
end
