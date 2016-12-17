require "spec_helper"
require "./app/presenters/assignments/presenter"
require "./app/presenters/assignments/group_presenter"

describe Assignments::Presenter do
  let(:assignment) { double(:assignment, id: 1, name: "Crazy Wizardry", pass_fail?: false, full_points: 5000)}
  let(:course) { double(:course) }
  let(:view_context) { double(:view_context) }
  let(:team) { double(:team) }
  subject { Assignments::Presenter.new({ assignment: assignment, course: course, view_context: view_context }) }

  describe "#assignment" do
    it "is the assignment that is passed in as a property" do
      expect(subject.assignment).to eq assignment
    end
  end

  describe "#course" do
    it "returns the course that is passed in as a property" do
      expect(subject.course).to eq course
    end
  end

  describe "#for_team?" do
    it "returns false if there was not a team id specified" do
      expect(subject.for_team?).to eq false
    end

    it "returns false if the team was not found on the course" do
      subject.properties[:team_id] = 123
      allow(subject.course).to receive(:teams).and_return double(:relation, find_by: nil)
      expect(subject.for_team?).to eq false
    end

    it "returns true if the team was found" do
      subject.properties[:team_id] = 123
      allow(subject.course).to receive(:teams).and_return double(:relation, find_by: team)
      expect(subject.for_team?).to eq true
    end
  end

  describe "#groups" do
    it "wraps the assignment groups in an Assignment::GroupPresenter" do
      groups = double(:groups, order_by_name: [double(:group), double(:group)])
      allow(assignment).to receive(:groups).and_return groups
      expect(subject.groups.map(&:class).uniq).to eq [Assignments::GroupPresenter]
      expect(subject.groups.first.group).to eq groups.order_by_name.first
    end
  end

  describe "#has_scores_for?" do
    let(:user) { double(:user) }

    it "does not have scores if the scores are nil" do
      allow(subject).to receive(:scores_for).and_return nil
      expect(subject.has_scores_for?(user)).to eq false
    end

    it "does not have scores if the scores are empty" do
      allow(subject).to receive(:scores_for).and_return Hash.new
      expect(subject.has_scores_for?(user)).to eq false
    end

    it "does not have scores if the scores is not in the right format" do
      allow(subject).to receive(:scores_for).and_return({ blah: [1, 2] })
      expect(subject.has_scores_for?(user)).to eq false
    end

    it "does not have scores if the scores returned are empty" do
      allow(subject).to receive(:scores_for).and_return({ scores: [] })
      expect(subject.has_scores_for?(user)).to eq false
    end

    it "has scores if the scores returned are not empty" do
      allow(subject).to receive(:scores_for).and_return({ scores: [1,2] })
      expect(subject.has_scores_for?(user)).to eq true
    end
  end

  describe "#show_analytics?" do
    it "is hidden if the course does not hide analytics but the assignment does" do
      allow(course).to receive(:show_analytics?).and_return true
      allow(assignment).to receive(:hide_analytics?).and_return true
      expect(subject.hide_analytics?).to eq true
    end

    it "is hidden if the assignment does not hide analytics but the course does" do
      allow(course).to receive(:show_analytics?).and_return false
      allow(assignment).to receive(:hide_analytics?).and_return false
      expect(subject.hide_analytics?).to eq true
    end

    it "is hidden if both the assignment and course hide analytics" do
      allow(course).to receive(:show_analytics?).and_return false
      allow(assignment).to receive(:hide_analytics?).and_return true
      expect(subject.hide_analytics?).to eq true
    end
  end

  describe "#grade_with_rubric?" do
    it "is not to be used if the assignment doesn't grade with a rubric" do
      allow(assignment).to receive(:grade_with_rubric?).and_return false
      expect(subject.grade_with_rubric?).to eq false
    end
  end

  describe "#show_rubric_preview?" do
    before do
      allow(subject).to receive(:grade_with_rubric?).and_return true
      allow(subject).to receive(:grades_available_for?).and_return false
      allow(assignment).to receive(:description_visible_for_student?).and_return true
    end

    let(:user) { double(:user) }

    it "is true when all criteria are met" do
      expect(subject.show_rubric_preview?(user)).to eq(true)
    end

    it "is false if not grading with a rubric" do
      allow(subject).to receive(:grade_with_rubric?).and_return false
      expect(subject.show_rubric_preview?(user)).to eq(false)
    end

    it "is false if user has available grades" do
      allow(subject).to receive(:grades_available_for?).and_return true
      expect(subject.show_rubric_preview?(user)).to eq(false)
    end

    it "is true if there is no user" do
      allow(assignment).to receive(:description_visible_for_student?).and_return false
      expect(subject.show_rubric_preview?(nil)).to eq(true)
    end

    it "is false if the description_visible_for_student is false" do
      allow(assignment).to receive(:description_visible_for_student?).and_return false
      expect(subject.show_rubric_preview?(user)).to eq(false)
    end
  end

  describe "#students" do
    let(:student) { double(:user) }

    it "returns the students that are attached to the course" do
      allow(course).to receive(:teams).and_return double(:relation, find_by: team)
      allow(User).to receive(:students_being_graded_for_course).and_return double(:collection, order_by_name: [student])
      expect(subject.students.class).to eq Assignments::Presenter::AssignmentStudentCollection
    end
  end

  describe "#team" do
    it "returns the team for the team id from the course" do
      allow(course).to receive(:teams).and_return double(:relation, find_by: team)
      expect(subject.team).to eq team
    end
  end

  describe "#has_viewable_submission?" do
    let(:user) { double(:user, id: 1) }
    let(:submission) { double(:submission) }

    context "when the submission exists" do
      before(:each) { allow(Submission).to receive(:for_assignment_and_student).and_return [submission] }

      it "is false if the assignment doesn't accept submissions" do
        allow(assignment).to receive(:accepts_submissions?).and_return false
        expect(subject.has_viewable_submission_for?(user)).to eq false
      end

      it "is false if the submission is not viewable" do
        allow(assignment).to receive(:accepts_submissions?).and_return(true)
        allow_any_instance_of(SubmissionProctor).to receive(:viewable?).and_return false
        expect(subject.has_viewable_submission_for?(user)).to eq false
      end

      it "is true when all criteria are met" do
        allow(assignment).to receive(:accepts_submissions?).and_return(true)
        allow_any_instance_of(SubmissionProctor).to receive(:viewable?).and_return true
        expect(subject.has_viewable_submission_for?(user)).to eq true
      end
    end

    context "when the submission does not exist" do
      before(:each) { allow(Submission).to receive(:for).and_return [] }

      it "is false" do
        allow(assignment).to receive(:accepts_submissions?).and_return true
        expect(subject.has_viewable_submission_for?(user)).to eq false
      end
    end
  end

  describe "#has_viewable_submission_for?" do
    let(:user) { double(:user, id: 1) }
    let(:submission) { double(:submission) }

    it "checks if there is a viewable submission" do
      allow(Submission).to receive(:for_assignment_and_student).and_return [submission]
      expect(subject).to receive(:has_viewable_submission?).with(submission, user)
      subject.has_viewable_submission_for?(user)
    end
  end
end
