describe Assignments::GroupPresenter do
  let(:assignment) { double(:assignment) }
  let(:group) { double(:group, name: "My Group") }
  let(:submission) { double(:submission) }
  subject { Assignments::GroupPresenter.new({ assignment: assignment, group: group })}

  describe "#grade_for_student" do
    it "returns the grade for the specified student" do
      grade = double(:grade)
      grades= double(:relation, find_by: grade)
      allow(assignment).to receive(:grades).and_return grades
      expect(subject.grade_for_student(double(:user, id: 123))).to eq grade
    end
  end

  describe "#student_weightable?" do
    it "returns the value for the assignment" do
      allow(assignment).to receive(:assignment_type)
        .and_return double(:assignment_type, student_weightable?: true)
      expect(subject.student_weightable?).to eq(true)
    end
  end

  describe "#has_levels?" do
    it "returns the value for the assignment" do
      allow(assignment).to receive(:has_levels?).and_return true
      expect(subject.has_levels?).to eq(true)
    end
  end

  describe "#pass_fail?" do
    it "returns the value for the assignment" do
      allow(assignment).to receive(:pass_fail?).and_return true
      expect(subject.pass_fail?).to eq(true)
    end
  end

  describe "#grade_level(grade)" do
    it "returns the value for the assignment" do
      grade = double(:grade)
      grade_level = double(:grade_level)
      allow(assignment).to receive(:grade_level)
        .with(grade).and_return grade_level
      expect(subject.grade_level(grade)).to eq(grade_level)
    end
  end

  describe "#has_submission?" do
    it "has a submission if one is returned for the assignment" do
      allow(group).to receive(:submission_for_assignment).and_return submission
      expect(subject).to have_submission
    end
  end

  describe "#submission" do
    it "returns the submission for the assignment" do
      allow(group).to receive(:submission_for_assignment).and_return submission
      expect(subject.submission).to eq submission
    end
  end

  describe "#students" do
    it "returns the students for the group" do
      student = double(:user, grade_for_assignment: double(:grade, student_visible?: true))
      allow(group).to receive(:students).and_return [student]
      expect(subject.students).to eq ([student])
    end
  end

  describe "path helpers" do
    it "returns the path_for_new_submission" do
      submission = build(:submission, id: 777)
      allow(group).to receive(:id).and_return 333
      allow(group).to receive(:submission_for_assignment).and_return submission
      expect(subject.path_for_new_submission).to match(/\/assignments\/.*\/submissions\/new.777\?group_id=333/)
    end

    it "returns the path_for_grading_assignment" do
      allow(group).to receive(:id).and_return 333
      expect(subject.path_for_grading_assignment).to match(/\/assignments\/.*\/groups\/.*\/grade/)
    end
  end
end
