describe Gradable do
  subject { build(:assignment) }

  describe "ungraded student methods" do
    let!(:student_1) { create(:course_membership, :student, course: subject.course).user }
    let!(:student_2) { create(:course_membership, :student, course: subject.course).user }
    let!(:student_3) { create(:course_membership, :student, course: subject.course).user }
    let!(:student_4) { create(:course_membership, :student, course: subject.course).user }

    describe "#ungraded_students" do

      before do
        subject.save
        subject.grades.create student_id: student_1.id, raw_points: 8, status: "Graded"
        subject.grades.create student_id: student_2.id, raw_points: 8, status: "Released"
        subject.grades.create student_id: student_3.id, raw_points: 5, status: "In Progress"
      end

      it "returns all students without a 'Graded' or 'Released' grade for the assignment" do
        expect(subject.ungraded_students.count).to eq(2)
      end

      it "can add graded student for determining the 'next student'" do
        expect(subject.ungraded_students([student_1.id]).count).to eq(3)
        expect(subject.ungraded_students([student_1.id,student_2.id]).count).to eq(4)
      end
    end

    describe "#ungraded_students_with_submissions" do

      before do
        subject.save
        create :submission, assignment: subject, student: student_3
        create :submission, assignment: subject, student: student_4
      end

      it "returns all students without a 'Graded' or 'Released' grade for the assignment" do
        expect(subject.ungraded_students_with_submissions.count).to eq(2)
      end

      it "can add graded student for determining the 'next student'" do
        expect(subject.ungraded_students_with_submissions([student_1.id]).count).to eq(3)
        expect(subject.ungraded_students_with_submissions([student_1.id,student_2.id]).count).to eq(4)
      end
    end
  end
end

describe "#next_ungraded_student" do

  %w"Zenith Apex Middleton".each do |name|
    let!(name.downcase.to_sym) do
      create(:course_membership, :student, course: subject.course,
        user: create(:user,last_name: name)).user
    end
  end

  context "when accepting submissions" do
    before do
      create :submission, assignment: subject, student: zenith
      create :submission, assignment: subject, student: apex
    end

    it "returns the next student with a submission" do
      expect(subject.next_ungraded_student(apex).last_name).to eq("Zenith")
    end

    it "returns nil for the last student" do
      expect(subject.next_ungraded_student(zenith)).to be_nil
    end

    it "filters to team members if team present" do
      create :submission, assignment: subject, student: middleton
      team = create :team, course: subject.course
      create :team_membership, team: team, student: apex
      create :team_membership, team: team, student: zenith

      expect(subject.next_ungraded_student(apex, team).last_name).to eq("Zenith")
    end
  end

  context "when not accepting submissions" do
    before { subject.update accepts_submissions: false }

    it "returns the next student by last name" do
      expect(subject.next_ungraded_student(middleton).last_name).to eq("Zenith")
    end

    it "returns nil for the last student" do
      expect(subject.next_ungraded_student(zenith)).to be_nil
    end

    it "returns nil for student not in the list" do
      expect(subject.next_ungraded_student(create(:user))).to be_nil
    end

    it "filters to team members if team present" do
      team = create :team, course: subject.course
      create :team_membership, team: team, student: apex
      create :team_membership, team: team, student: zenith

      expect(subject.next_ungraded_student(apex, team).last_name).to eq("Zenith")
    end
  end
end

context "group assignments" do

  let!(:group_1) {create :approved_group, name: "A Group",course: subject.course}
  let!(:group_2) {create :approved_group, name: "Z Group",course: subject.course}
  let!(:group_3) {create :approved_group, name: "M Group",course: subject.course}

  before do
    subject.update(grade_scope: "Group")
    subject.groups << [group_1, group_2, group_3]
  end

  describe "#ungraded_groups" do
    before do
      group_1.students.each {|s| create(:released_grade, assignment: subject, student: s)}
    end

    it "returns all ungraded groups" do
      expect(subject.ungraded_groups.count).to eq(2)
    end

    it "can add graded group for determining the 'next group'" do
      expect(subject.ungraded_groups(group_1).count).to eq(3)
    end
  end

  describe "ungraded_groups_with_submissions" do
    before do
      group_1.students.each {|s| create(:released_grade, assignment: subject, student: s)}
      create :submission, assignment: subject, student: nil, group: group_1
      create :submission, assignment: subject, student: nil, group: group_2
    end

    it "returns all ungraded groups that have submitted" do
      expect(subject.ungraded_groups_with_submissions).to eq([group_2])
    end

    it "can add graded group for determining the 'next group'" do
      expect(subject.ungraded_groups_with_submissions(group_1).count).to eq(2)
    end
  end

  describe "next_ungraded_group" do
    context "when accepting submissions" do
      before do
        create :submission, assignment: subject, student: nil, group: group_1
        create :submission, assignment: subject, student: nil, group: group_2
      end

      it "returns the next ungraded group with a submission" do
        expect(subject.next_ungraded_group(group_1)).to eq(group_2)
      end

      it "returns nil for the last group with a submission" do
        expect(subject.next_ungraded_group(group_2)).to eq(nil)
      end
    end

    context "when not accepting submissions" do
      before { subject.update accepts_submissions: false }

      it "returns the next ungraded group" do
        expect(subject.next_ungraded_group(group_3)).to eq(group_2)
      end

      it "returns nil for the last group" do
        expect(subject.next_ungraded_group(group_2)).to eq(nil)
      end
    end
  end
end
