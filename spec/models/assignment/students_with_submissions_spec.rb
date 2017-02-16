require "spec_helper"

describe "Assignment #students_with_submissions methods" do
  let(:submission) { create(:submission, assignment: assignment, student: student) }
  let(:errant_submission) { create(:submission, student: errant_student) }
  let(:errant_student) { create(:user) }
  let(:assignment) { create(:assignment) }
  let(:student) { create(:user) }
  let(:cache_submissions) { submission; errant_submission }

  describe "#students_with_submissions" do
    subject { assignment.students_with_submissions }
    before(:each) { cache_submissions }

    describe "ordering" do
      let(:another_submission) { create(:submission, assignment: assignment, student: another_student) }
      let(:another_student) { create(:user) }
      let(:cache_submissions) { submission; errant_submission; another_submission }

      it "orders the students by name" do
        expect(subject.first.submitter_directory_name < subject.last.submitter_directory_name).to be_truthy
      end
    end

    it "returns students that have submissions for the assignment" do
      expect(subject).to include(student)
    end

    it "doesn't return students that don't have a submission for the assignment" do
      expect(subject).not_to include(errant_student)
    end
  end

  describe "#students_with_submissions_on_team" do
    subject { assignment.students_with_submissions_on_team(team_membership.team) }
    let(:team_membership) { create(:team_membership) }
    let(:team_submission) { create(:submission, assignment: assignment, student: team_membership.student) }
    let(:another_submission) { create(:submission, assignment: assignment, student: another_student) }
    let(:another_student) { create(:user) }
    let(:cache_submissions) { team_submission; errant_submission; another_submission }

    before(:each) { cache_submissions }

    describe "ordering" do
      let(:another_team_membership) { create(:team_membership, team: team_membership.team) }
      let(:another_submission) { create(:submission, assignment: assignment, student: another_team_membership.student) }

      it "orders the students by name" do
        expect(subject.first.submitter_directory_name < subject.last.submitter_directory_name).to be_truthy
      end
    end

    describe "team constraints" do
      it "returns students on the team that have submissions for the assignment" do
        expect(subject).to include(team_membership.student)
      end

      it "doesn't return students that have submissions for the assignment but aren't on the team" do
        expect(subject).not_to include(another_student)
      end
    end

    it "doesn't return students that don't have a submission for the assignment at all" do
      expect(subject).not_to include(errant_student)
    end
  end

  describe "finding students that have submitted text or binary files" do
    describe "#students_with_text_or_binary_files" do
      subject { assignment.students_with_text_or_binary_files }
      let(:submission) { create(:full_submission, assignment: assignment, student: student) }
      let(:empty_submission) { create(:empty_submission, student: empty_student, assignment: assignment) }
      let(:empty_student) { create(:user) }

      let(:cache_submissions) { submission; errant_submission; empty_submission }
      before(:each) { cache_submissions }

      describe "ordering" do
        let(:another_submission) { create(:full_submission, assignment: assignment, student: another_student) }
        let(:another_student) { create(:user) }
        let(:cache_submissions) { submission; errant_submission; another_submission }

        it "orders the students by name" do
          expect(subject.first.submitter_directory_name < subject.last.submitter_directory_name).to be_truthy
        end
      end

      it "returns students that have submissions with text or binary files for the assignment" do
        expect(subject).to include(student)
      end

      it "doesn't return students that don't have a submission for the assignment" do
        expect(subject).not_to include(errant_student)
      end

      it "doesn't return students that have a submission for the assignment, but one that has no relevant files" do
        expect(subject).not_to include(empty_student)
      end
    end

    describe "#students_with_text_or_binary_files_on_team" do
      subject { assignment.students_with_text_or_binary_files_on_team(team_membership.team) }

      let(:team_membership) { create(:team_membership) }
      let(:team_submission) { create(:full_submission, assignment: assignment, student: team_membership.student) }
      let(:another_submission) { create(:full_submission, assignment: assignment, student: another_student) }
      let(:another_student) { create(:user) }
      let(:empty_submission) { create(:empty_submission, student: empty_team_membership.student, assignment: assignment) }
      let(:empty_team_membership) { create(:team_membership, team: team_membership.team, student: empty_student) }
      let(:empty_student) { create(:user) }

      let(:cache_submissions) { team_submission; errant_submission; another_submission; empty_submission }
      let(:submission) { create(:full_submission, assignment: assignment, student: student) }

      before(:each) { cache_submissions }

      describe "ordering" do
        let(:another_team_membership) { create(:team_membership, team: team_membership.team) }
        let(:another_submission) { create(:submission, assignment: assignment, student: another_team_membership.student) }

        it "orders the students by name" do
          expect(subject.first.submitter_directory_name < subject.last.submitter_directory_name).to be_truthy
        end
      end

      describe "team constraints" do
        it "returns students on the team that have fileized submissions for the assignment" do
          expect(subject).to include(team_membership.student)
        end

        it "doesn't return students that have submissions for the assignment but aren't on the team" do
          expect(subject).not_to include(another_student)
        end

        it "doesn't return students that are on the team, and have submissions for the assignment, but for which there are no files" do
          expect(subject).not_to include(empty_student)
        end
      end

      it "doesn't return students that don't have a submission for the assignment at all" do
        expect(subject).not_to include(errant_student)
      end
    end
  end
end
