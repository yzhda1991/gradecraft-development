describe "Assignment #student_submissions methods" do
  let(:submission) { create(:submission, assignment: assignment) }
  let(:errant_submission) { create(:submission) }
  let(:assignment) { create(:assignment) }
  let(:student) { create(:user) }

  describe "#student_submissions_with_files" do
    subject { assignment.student_submissions_with_files }
    let(:submission) { create(:submission_with_submission_files, assignment: assignment, student: student) }
    before(:each) { submission }

    context "submission has only a text comment" do
      let(:submission) { create(:submission_with_text_comment_only, assignment: assignment) }
      it "returns the submission" do
        expect(subject).to include(submission)
      end
    end

    context "submission has only a link" do
      let(:submission) { create(:submission_with_link_only, assignment: assignment) }
      it "returns the submission" do
        expect(subject).to include(submission)
      end
    end

    context "submission has only a non-missing submission file" do
      let(:submission) { create(:submission_with_files_only, assignment: assignment) }
      it "returns the submission" do
        expect(subject).to include(submission)
      end
    end

    context "submission has no comment, no link, and only a missing submission file" do
      let(:submission) { create(:empty_submission, assignment: assignment) }
      it "returns an empty array" do
        expect(subject).to eq([])
      end
    end

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
      it "eager loads the whole affair" do
        expect { subject }.to make_database_queries
      end

      it "includes associated submission files" do
        subject
        expect { subject.first.submission_files }.not_to make_database_queries
      end

      it "includes associated student" do
        subject
        expect { subject.first.student }.not_to make_database_queries
      end
    end
  end

  describe "#student_submissions_with_files_for_team" do
    subject { assignment.student_submissions_with_files_for_team(team_membership.team) }
    let(:team_membership) { create(:team_membership) }
    let(:team_submission) { create(:submission_with_submission_files, assignment: assignment, student: team_membership.student) }
    let(:errant_team_submission) { create(:submission_with_submission_files, assignment: assignment, student: student) }
    before(:each) { team_submission }

    context "submission has only a text comment" do
      let(:team_submission) { create(:submission_with_text_comment_only, assignment: assignment, student: team_membership.student) }
      it "returns the submission" do
        expect(subject).to include(team_submission)
      end
    end

    context "submission has only a link" do
      let(:team_submission) { create(:submission_with_link_only, assignment: assignment, student: team_membership.student) }
      it "returns the submission" do
        expect(subject).to include(team_submission)
      end
    end

    context "submission has only a non-missing submission file" do
      let(:team_submission) { create(:submission_with_files_only, assignment: assignment, student: team_membership.student) }
      it "returns the submission" do
        expect(subject).to include(team_submission)
      end
    end

    context "submission has no comment, no link, and only a missing submission file" do
      let(:team_submission) { create(:empty_submission, assignment: assignment, student: team_membership.student) }
      it "returns an empty array" do
        expect(subject).to eq([])
      end
    end

    it "returns submissions that belong to the assignment" do
      expect(subject).to include(team_submission)
    end

    it "doesn't return submissions that don't belong to it" do
      expect(subject).not_to include(errant_submission)
    end

    it "doesn't return submissions that don't belong to the team" do
      expect(subject).not_to include(errant_team_submission)
    end

    it "returns an array" do
      expect(subject.class).to eq(Array)
    end

    describe "eager loading" do
      it "eager loads the whole affair" do
        expect { subject }.to make_database_queries
      end

      it "includes associated submission files" do
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
