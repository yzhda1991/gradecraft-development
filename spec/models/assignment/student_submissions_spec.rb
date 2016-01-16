require "rails_spec_helper"

describe "Assignment #student_submissions methods" do
  let(:submission) { create(:submission, assignment: assignment) }
  let(:errant_submission) { create(:submission) }
  let(:assignment) { create(:assignment) }

  describe "#student_submissions" do
    subject { assignment.student_submissions }
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

  describe "#student_submissions_for_team" do
    subject { assignment.student_submissions_for_team(team_membership.team) }
    let(:team_membership) { create(:team_membership) }
    let(:team_submission) { create(:submission, assignment: assignment, student: team_membership.student) }

    before(:each) { team_submission }

    it "returns submissions that belong to the assignment" do
      expect(subject).to include(team_submission)
    end

    it "doesn't return submissions that don't belong to it" do
      expect(subject).not_to include(errant_submission)
    end

    it "returns an array" do
      expect(subject.class).to eq(Array)
    end

    describe "eager loading" do
      let(:team_submission) { create(:submission_with_submission_files, assignment: assignment, student: team_membership.student) }
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
end
