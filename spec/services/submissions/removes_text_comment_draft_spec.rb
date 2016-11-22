require "rails_spec_helper"
require "./app/services/submissions/removes_text_comment_draft"

describe Services::Actions::RemovesTextCommentDraft do
  let(:submission) { create(:submission, text_comment_draft: "Dear Mr. Professor, ") }

  it "expects a submission" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "deletes the draft of the text comment" do
    described_class.execute submission: submission
    expect(submission.reload.text_comment_draft).to be_nil
  end
end
