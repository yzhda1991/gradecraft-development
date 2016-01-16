require "rails_spec_helper"

describe "Assignment #student_submissions methods" do
  let(:submission) { create(:submission, assignment: assignment) }
  let(:assignment) { create(:assignment) }

  describe "#student_submissions" do
    subject { assignment.student_submissions }
    let(:errant_submission) { create(:submission) }
    before(:each) { submission }

    it "returns submissions that belong to the assignment" do
      expect(subject).to include(submission)
    end

    it "doesn't return submissions that don't belong to it" do
      expect(subject).not_to include(errant_submission)
    end

    it "returns an array" do
      expect(subject.class).to eq(Array)
    end

    describe "eager loading" do
      let(:submission) { create(:submission_with_submission_files, assignment: assignment, student: create(:user)) }
      it "eager loads the whole affair" do
        expect { subject }.to make_database_queries
      end

      it "includes associated students" do
        subject
        expect { subject.first.submission_files }.not_to make_database_queries
      end

      it "includes associated student" do
        subject
        expect { subject.first.student }.not_to make_database_queries
      end
    end
  end

  describe "
end
