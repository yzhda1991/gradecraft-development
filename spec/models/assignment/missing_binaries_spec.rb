require "rails_spec_helper"

RSpec.describe "Assignment #missing_binaries methods" do
  let(:missing_submission_file) { create(:missing_submission_file, submission: submission_with_missing_file) }
  let(:submission_with_missing_file) { create(:submission, assignment: assignment, student: student1) }
  let(:student1) { create(:user) }

  let(:present_submission_file) { create(:present_submission_file, submission: submission_with_present_file) }
  let(:submission_with_present_file) { create(:submission, assignment: assignment, student: student2) }
  let(:student2) { create(:user) }

  let(:another_missing_submission_file) { create(:missing_submission_file, submission: another_submission_with_missing_file) }
  let(:another_submission_with_missing_file) { create(:submission, assignment: assignment, student: student3) }
  let(:student3) { create(:user) }

  let(:assignment) { create(:assignment) }
  let(:cache_submission_files) { missing_submission_file; present_submission_file }

  before(:each) { cache_submission_files }

  context "no team is given" do
    describe "#submission_files_with_missing_binaries" do
      subject { assignment.submission_files_with_missing_binaries }

      context "submission file is marked 'file_missing'" do
        it "returns missing submission_files for the the assignment" do
          expect(subject).to include(missing_submission_file)
        end
      end

      context "submission file is not marked 'file_missing'" do
        it "doesn't return non-missing submission files" do
          expect(subject).not_to include(present_submission_file)
        end
      end

      describe "ordering" do
        let(:cache_submission_files) { missing_submission_file; present_submission_file; another_missing_submission_file }

        it "orders the students by create_at ASC" do
          expect(subject.index(missing_submission_file)).to be < subject.index(another_missing_submission_file)
        end
      end

      describe "assignment association" do
        let(:cache_submission_files) { missing_submission_file; present_submission_file; another_missing_submission_file }
        let(:another_submission_with_missing_file) { create(:submission, student: student3) } # some other assignment

        context "submission file is associated with submission for that assignment" do
          it "returns the submission file" do
            expect(subject).to include(missing_submission_file)
          end
        end

        context "submission_file is associated with another assignment" do
          it "doesn't return the submission file" do
            expect(subject).not_to include(another_missing_submission_file)
          end
        end
      end
    end

    describe "#students_with_missing_binaries" do
      subject { assignment.students_with_missing_binaries }

      it "returns students that have submissions for the assignment" do
        expect(subject).to include(student1)
      end

      it "doesn't return students that don't have a submission for the assignment" do
        expect(subject).not_to include(student2)
      end

      describe "ordering" do
        let(:cache_submission_files) { missing_submission_file; present_submission_file; another_missing_submission_file }

        it "orders the students by name" do
          expect(subject.first.alphabetical_name_key < subject.last.alphabetical_name_key).to be_truthy
        end
      end

      describe "assignment association" do
        let(:cache_submission_files) { missing_submission_file; present_submission_file; another_missing_submission_file }
        let(:another_submission_with_missing_file) { create(:submission, student: student3) } # some other assignment

        context "user has submissions with missing files for the assignment" do
          it "returns the user with those files" do
            expect(subject).to include(student1)
          end
        end

        context "user has submissions with missing files that don't belong to the assignment" do
          it "doesn't return the user whose files belong to the third-party assignment" do
            expect(subject).not_to include(student3)
          end
        end
      end
    end
  end

  context "a team is given" do
    let(:team)( { create(:team) } )
    let(:team_membership) { create(:team_membership, team: team, student: student1) }

    let(:cache_submission_files) { missing_submission_file; present_submission_file; another_missing_submission_file }

    describe "#submission_files_with_missing_binaries_for_team" do
      subject { assignment.submission_files_with_missing_binaries_for_team(team) }

      context "submission file is marked 'file_missing'" do
        it "returns missing submission_files for the the assignment" do
          expect(subject).to include(missing_submission_file)
        end
      end

      context "submission file is not marked 'file_missing'" do
        it "doesn't return non-missing submission files" do
          expect(subject).not_to include(present_submission_file)
        end
      end

      describe "ordering" do
        let(:cache_submission_files) { missing_submission_file; present_submission_file; another_missing_submission_file }

        it "orders the students by create_at ASC" do
          expect(subject.index(missing_submission_file)).to be < subject.index(another_missing_submission_file)
        end
      end

      describe "assignment association" do
        let(:cache_submission_files) { missing_submission_file; present_submission_file; another_missing_submission_file }
        let(:another_submission_with_missing_file) { create(:submission, student: student3) } # some other assignment

        context "submission file is associated with submission for that assignment" do
          it "returns the submission file" do
            expect(subject).to include(missing_submission_file)
          end
        end

        context "submission_file is associated with another assignment" do
          it "doesn't return the submission file" do
            expect(subject).not_to include(another_missing_submission_file)
          end
        end
      end
    end
  end
end
