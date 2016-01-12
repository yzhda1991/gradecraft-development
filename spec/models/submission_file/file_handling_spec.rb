require "rails_spec_helper"

describe SubmissionFile do
  let(:course) { build(:course) }
  let(:assignment) { build(:assignment) }
  let(:student) { build(:user) }
  let(:submission) { build(:submission, course: course, assignment: assignment, student: student) }
  let(:submission_file) { submission.submission_files.last }

  describe "#confirmed?" do
    subject { submission_file.confirmed? }

    context "has a last_confirmed_at time and the file isn't missing" do
      let(:submission_file) { build(:submission_file, last_confirmed_at: Time.now, file_missing: false) }
      it "is confirmed" do
        expect(subject).to be_truthy
      end
    end

    context "has no last_confirmed_at time" do
      let(:submission_file) { build(:submission_file, last_confirmed_at: nil, file_missing: false) }
      it "is not confirmed" do
        expect(subject).to be_falsey
      end
    end

    context "the file is missing" do
      let(:submission_file) { build(:submission_file, last_confirmed_at: Time.now, file_missing: true) }
      it "is not confirmed" do
        expect(subject).to be_falsey
      end
    end
  end

  describe "#missing?" do
    subject { submission_file.missing? }

    context "has a last_confirmed_at time and the file is missing" do
      let(:submission_file) { build(:submission_file, last_confirmed_at: Time.now, file_missing: true) }
      it "is missing" do
        expect(subject).to be_truthy
      end
    end

    context "has no last_confirmed_at time" do
      let(:submission_file) { build(:submission_file, last_confirmed_at: nil, file_missing: true) }
      it "is not missing" do
        expect(subject).to be_falsey
      end
    end

    context "the file is not missing" do
      let(:submission_file) { build(:submission_file, last_confirmed_at: Time.now, file_missing: false) }
      it "is not confirmed" do
        expect(subject).to be_falsey
      end
    end
  end
  
  describe "#needs_confirmation?" do
    subject { submission_file.needs_confirmation? }

    context "last_confirmed_at is nil" do
      let(:submission_file) { build(:submission_file, last_confirmed_at: nil) }
      it "needs confirmation" do
        expect(subject).to be_truthy
      end
    end

    context "it has a last_confirmed_at time" do
      let(:submission_file) { build(:submission_file, last_confirmed_at: Time.now) }
      it "is does not need confirmation" do
        expect(subject).to be_falsey
      end
    end
  end

  describe "#source_file_url" do
    subject { submission_file.source_file_url }
    let(:submission_file) { build(:submission_file) }

    before(:each) do
      allow(submission_file).to receive(:public_url) { "/some/file/path/srsly.txt" }
      allow(submission_file).to receive(:url) { "http://werewolf.com" }
    end

    context "Rails environment is development" do
      before { allow(Rails).to receive(:env) { ActiveSupport::StringInquirer.new("development") }}
      it "uses the public url" do
        expect(subject).to eq("/some/file/path/srsly.txt")
      end
    end

    context "Rails env is anything but development" do
      before { allow(Rails).to receive(:env) { ActiveSupport::StringInquirer.new("badgerenv") }}
      it "uses the url method from S3File" do
        expect(subject).to eq("http://werewolf.com")
      end
    end
  end

  describe "#s3_manager" do
    subject { submission_file.s3_manager }
    let(:submission_file) { build(:submission_file) }

    it "creates an S3Manager::Manager object" do
      expect(subject.class).to eq(S3Manager::Manager)
    end

    it "caches the S3Manager object" do
      subject
      expect(S3Manager::Manager).not_to receive(:new)
      subject
    end
  end

end
