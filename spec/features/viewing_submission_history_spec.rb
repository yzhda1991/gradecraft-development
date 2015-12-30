require "rails_spec_helper"

feature "viewing submission history" do
  context "as a professor" do
    let!(:submission) do
      create :submission, course: membership.course, assignment: assignment, student: student
    end

    let(:assignment) { create :assignment, accepts_submissions: true, course: membership.course }
    let(:membership) { create :student_course_membership, user: student }
    let(:professor) { create :user }
    let!(:professor_membership) { create :professor_course_membership, user: professor, course: membership.course }
    let(:student) { create :user }

    before { login_as professor }

    scenario "with some history" do
      previous_comment = submission.text_comment
      PaperTrail.whodunnit = student.id
      submission.update_attributes text_comment: "This is an updated comment"
      visit assignment_submission_path assignment, submission, anchor: "history"
      expect(page).to have_content "#{student.name} changed the text comment from \"#{previous_comment}\" to \"This is an updated comment\""
    end
  end
end
