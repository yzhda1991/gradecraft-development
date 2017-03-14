require "toolkits/historical_toolkit"

describe "Submission file checking" do
  let(:submission) { create(:submission, submission_files: submission_files) }
  let(:unconfirmed_submission_file) { create(:unconfirmed_submission_file) }
  let(:confirmed_submission_file) { create(:confirmed_submission_file) }
  let(:submission_files) { [ unconfirmed_submission_file, confirmed_submission_file ] }

  before(:each) do
    allow(unconfirmed_submission_file).to receive(:check_and_set_confirmed_status) { "thanks" }
    allow(confirmed_submission_file).to receive(:check_and_set_confirmed_status) { "no thanks" }
  end

  describe "#process_unconfirmed_files" do
    subject { submission.process_unconfirmed_files }
    before { allow(submission).to receive_message_chain(:submission_files, :unconfirmed) { [ unconfirmed_submission_file ] }}

    it "checks and sets confirmed status for unconfirmed files" do
      expect(unconfirmed_submission_file).to receive(:check_and_set_confirmed_status)
    end

    it "doesn't bother with confirmed files" do
      expect(confirmed_submission_file).not_to receive(:check_and_set_confirmed_status)
    end

    after(:each) { subject }
  end

  describe "#confirm_all_files" do
    subject { submission.confirm_all_files }

    it "checks and sets confirmed status for unconfirmed files" do
      expect(unconfirmed_submission_file).to receive(:check_and_set_confirmed_status)
    end

    it "checks and sets confirmed status for confirmed files too" do
      expect(confirmed_submission_file).to receive(:check_and_set_confirmed_status)
    end

    after(:each) { subject }
  end
end
