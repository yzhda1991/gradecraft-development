require "active_record_spec_helper"

describe SubmissionFile do
  let(:course) { build(:course) }
  let(:assignment) { build(:assignment) }
  let(:student) { build(:user) }
  let(:submission) { build(:submission, course: course, assignment: assignment, student: student) }

  subject { submission.submission_files.new(filename: "test", file: fixture_file('test_image.jpg', 'img/jpg')) }

  describe "validations" do
    it { is_expected.to be_valid }

    it "requires a filename" do
      subject.filename = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:filename]).to include "can't be blank"
    end
  end

  describe "versioning", versioning: true do
    before { subject.save }

    it "is enabled for submissions" do
      expect(PaperTrail).to be_enabled
      expect(subject).to be_versioned
    end
  end

  describe "#course" do
    it "returns the course associated with the submission" do
      expect(subject.course).to eq(course)
    end
  end

  describe "#assignment" do
    it "returns the assignment associated with the submission" do
      expect(subject.assignment).to eq(assignment)
    end
  end

  describe "#student" do
    it "returns the student associated with the submission" do
      expect(subject.student).to eq(student)
    end
  end

  describe "as a dependency of the submission" do
    it "is saved when the parent submission is saved" do
      subject.submission.save!
      expect(subject.submission_id).to equal submission.id
      expect(subject.new_record?).to be_falsey
    end

    it "is deleted when the parent submission is destroyed" do
      subject.submission.save!
      expect {submission.destroy}.to change(SubmissionFile, :count).by(-1)
    end
  end

  it "accepts text files as well as images" do
    subject.file = fixture_file('test_file.txt', 'txt')
    subject.submission.save!
    expect expect(subject.url).to match(/.*\/uploads\/submission_file\/file\/#{subject.id}\/\d+_test_file\.txt/)
  end

  it "accepts multiple files" do
    submission.submission_files.new(filename: "test", filepath: 'uploads/submission_file/', file: fixture_file('test_file.txt', 'img/jpg'))
    subject.submission.save!
    expect(submission.submission_files.count).to equal 2
  end

  it "has an accessible url" do
    subject.submission.save!
    expect expect(subject.url).to match(/.*\/uploads\/submission_file\/file\/#{subject.id}\/\d+_test_image\.jpg/)
  end

  it "shortens and removes non-word characters from file names on save" do
    subject.file = fixture_file('Too long, strange characters, and Spaces (In) Name.jpg', 'img/jpg')
    subject.submission.save!
    expect expect(subject.url).to match(/.*\/uploads\/submission_file\/file\/#{subject.id}\/\d+_too_long__strange_characters__and_spaces_\.jpg/)
  end
end
