feature "editing submissions" do
  context "as a student" do
    let!(:institution) { create :institution }
    let(:course) { build :course, institution: institution }
    let(:assignment) { build :assignment, accepts_submissions: true, resubmissions_allowed: true, course: membership.course }
    let(:membership) { create :course_membership, :student, user: student }
    let!(:student) { create :user }

    let!(:submission) do
      create :submission, course: membership.course, assignment: assignment, student: student, link: "http://ai.umich.edu"
    end
    let!(:grade) { create :grade, student_visible: true, student: student, submission: submission, assignment: assignment }

    before(:each) do
      login_as student
    end

    scenario "notification of a resubmission" do

      visit assignment_path(assignment)

      within(".pageContent") do
        click_link "Resubmit"
      end

      expect(current_path).to eq edit_assignment_submission_path(assignment, submission)

      expect(page).to have_content "Resubmission!"
    end
  end
end
