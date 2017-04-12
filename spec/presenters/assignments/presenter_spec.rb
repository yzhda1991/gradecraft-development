describe Assignments::Presenter do
  let(:course) { build(:course) }
  let(:assignment) { create(:assignment, id: 1, name: "Crazy Wizardry", pass_fail: false, full_points: 5000)}
  let(:view_context) { double(:view_context) }
  let(:team) { double(:team) }
  let(:student) { create(:user) }
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
    let(:professor) { create(:course_membership, :professor, course: course).user }

    context "when the assignment accepts submissions" do
      before(:each) { allow(assignment).to receive(:accepts_submissions?).and_return true }

      it "is false if the submission is nil" do
        expect(subject.has_viewable_submission?(student, student)).to eq false
      end

      it "is visible for the student who owns it" do
        allow(SubmissionProctor).to receive(:viewable?).and_return true
        create(:submission, assignment: assignment, student: student)
        expect(subject.has_viewable_submission?(student, student)).to eq true
      end

      it "is visible for staff in the course if the SubmissionProctor is satisifed" do
        allow(SubmissionProctor).to receive(:viewable?).and_return true
        create(:submission, assignment: assignment, student: student)
        expect(subject.has_viewable_submission?(student, professor)).to eq true
      end

      it "is not visible for staff in the course if the SubmissionProctor says no" do
        allow(SubmissionProctor).to receive(:viewable?).and_return false
        create(:submission, assignment: assignment, student: student, submitted_at: nil)
        expect(subject.has_viewable_submission?(student, professor)).to eq false
      end
    end

    context "when the assignment does not accept submissions" do
      before(:each) { allow(assignment).to receive(:accepts_submissions?).and_return false }

      it "is false" do
        expect(subject.has_viewable_submission?(student, professor)).to eq false
      end
    end
  end

  describe "#has_viewable_analytics?" do
    let(:user) { double(:user) }
    let(:analytics_proctor) { double(:analytics_proctor) }

    before(:each) { allow(AnalyticsProctor).to receive(:new).and_return analytics_proctor }

    it "returns true if it's viewable according to the analytics proctor and hide_analytics? is false" do
      allow(analytics_proctor).to receive(:viewable?).with(user, course).and_return true
      allow(assignment).to receive(:hide_analytics?).and_return false
      expect(subject.has_viewable_analytics?(user)).to be_truthy
    end

    it "returns false if it's viewable according to the analytics proctor and hide_analytics? is true" do
      allow(analytics_proctor).to receive(:viewable?).with(user, course).and_return true
      allow(assignment).to receive(:hide_analytics?).and_return true
      expect(subject.has_viewable_analytics?(user)).to be_falsey
    end

    it "returns false if it's not viewable according to the analytics proctor" do
      allow(analytics_proctor).to receive(:viewable?).with(user, course).and_return false
      expect(subject.has_viewable_analytics?(user)).to be_falsey
    end
  end
end
