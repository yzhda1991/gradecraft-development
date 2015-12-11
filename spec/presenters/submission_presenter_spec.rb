require "spec_helper"
require "./app/presenters/submission_presenter"

describe SubmissionPresenter do
  let(:submission) { double(:submission) }
  subject { described_class.new submission: submission }

  describe "#submission" do
    it "is the submission that is passed in as a property" do
      expect(subject.submission).to eq submission
    end
  end
end
