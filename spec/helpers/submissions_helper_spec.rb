require "rails_spec_helper"
require "./app/helpers/submissions_helper"

describe SubmissionsHelper do
  let(:course) { create :course }

  describe "#resubmission_count_for" do
    let!(:grade) { create :grade, course: course, status: "Released", submission: submission,
                   graded_at: 1.day.ago
                 }
    let(:submission) { create :submission, course: course, submitted_at: DateTime.now }

    it "returns the number of resubmitted submissions" do
      expect(resubmission_count_for(course)).to eq 1
    end

    it "caches the result" do
      expect(course).to receive(:submissions).and_call_original.at_most(:twice)
      resubmission_count_for(course)
      resubmission_count_for(course)
      Rails.cache.delete resubmission_count_cache_key(course)
      resubmission_count_for(course)
    end
  end

  describe "#ungraded_submissions_count_for" do
    let!(:submission) { create :submission, course: course }
    let!(:draft_submission) { create :draft_submission, course: course }

    context "when not including draft submissions" do
      it "returns the number of ungraded draft submissions" do
        expect(ungraded_submissions_count_for(course)).to eq 1
      end
    end

    context "when including draft submissions" do
      it "returns the number of ungraded submissions" do
        expect(ungraded_submissions_count_for(course, true)).to eq 2
      end
    end

    it "caches the result" do
      expect(course).to receive(:submissions).and_call_original.at_most(:twice)
      ungraded_submissions_count_for(course)
      ungraded_submissions_count_for(course)
      Rails.cache.delete ungraded_submissions_count_cache_key(course)
      ungraded_submissions_count_for(course)
    end
  end
end
