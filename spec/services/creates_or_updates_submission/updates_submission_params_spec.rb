describe Services::Actions::UpdateSubmissionParams do
  let!(:course) { create :course }
  let!(:student) { create(:course_membership, :student, course: course).user }
  let!(:assignment) { create :assignment }
  let!(:submission) { create :submission, assignment_id: assignment.id, student_id: student.id, resubmission: false }
  let!(:grade) { create :grade, student_id: student.id, assignment_id: assignment.id, student_visible: true }

  it "saves the submission" do
    new_submission = build(:submission, assignment: assignment)
    expect { described_class.execute assignment: assignment, submission: new_submission }.to \
      change { Submission.count }
  end

end
