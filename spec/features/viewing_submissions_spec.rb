require "rails_spec_helper"

feature "viewing submissions" do
  let(:assignment) { create :assignment, accepts_submissions: true, course: membership.course }
  let!(:submission) do
    create :submission, course: membership.course, assignment: assignment, student: student
  end
  let(:student) { create :user }

  context "as a student", versioning: true do
    let(:membership) { create :student_course_membership, user: student }

    before { login_as student }

    scenario "allows an editable submission if it's before the due date" do
      visit assignment_path assignment

      expect(find_link("Edit My Submission")).to be_visible
    end

    scenario "displays a resubmitted alert for a resubmitted submission" do
      create :grade, submission: submission, assignment: assignment, student: student,
        raw_score: 10000, status: "Released"
      submission.update_attributes link: "http://example.org"
      visit assignment_path assignment

      within ".pageContent" do
        expect(page).to have_content "Resubmission!"
      end
    end
  end

  context "as a professor", versioning: true do
    let(:membership) { create :professor_course_membership, user: professor }
    let(:professor) { create :user }

    before do
      login_as professor
      grade = create :grade, submission: submission, assignment: assignment, student: student, raw_score: 10000, status: "Released"
      submission.update_attributes link: "http://example.org"
      grade.update_attributes raw_score: 1234 # TODO: Does a resubmission mean that it has a grade?
      visit assignment_submission_path assignment, submission
    end

    scenario "displays a resubmitted alert for a resubmitted submission" do
      within ".pageContent" do
        expect(page).to have_content "Resubmission!"
      end
    end
  end
end
