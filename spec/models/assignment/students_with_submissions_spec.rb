require "rails_spec_helper"

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
        expect(subject.first.alphabetical_name_key < subject.last.alphabetical_name_key).to be_truthy
      end
    end

    it "returns students that have submissions for the assignment" do
      expect(subject).to include(student)
    end

    it "doesn't return students that don't have a submission for the assignment" do
      expect(subject).not_to include(errant_student)
    end
  end
end
