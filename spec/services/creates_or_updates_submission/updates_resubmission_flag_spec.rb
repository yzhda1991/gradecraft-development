describe Services::Actions::UpdatesResubmissionFlag do
  let!(:course) { create :course }
  let!(:student) { create(:course_membership, :student, course: course).user }
  let!(:assignment) { create :assignment }
  let!(:submission) { create :submission, assignment_id: assignment.id, student_id: student.id, resubmission: false }
  let!(:grade) { create :grade, student_id: student.id, assignment_id: assignment.id, student_visible: true }

  it "flips the resubmission flag if individual grade exists" do
    expect { described_class.execute assignment: assignment, submission: submission}.to \
      change { Submission.resubmitted.count }
  end

  it "flips the resubmission flag if group grade exists" do
    group_assignment = build(:assignment, grade_scope: "Group")
    group_submission = build(:group_submission, assignment: group_assignment)
    student1 = create(:user)
    student2 = create(:user)
    group = create(:group, assignments: [submission.assignment])
    group.students << [student1, student2]
    grade1 = create(:student_visible_grade, assignment: group_assignment, student: student1, group: group, graded_at: 1.day.ago)
    grade2 = create(:student_visible_grade, assignment: group_assignment, student: student2, group: group, graded_at: 1.day.ago)
    group_submission.submitted_at = DateTime.now
    group_submission.group_id = group.id
    expect { described_class.execute assignment: group_assignment, submission: group_submission}.to \
      change { Submission.resubmitted.count }
  end

end
