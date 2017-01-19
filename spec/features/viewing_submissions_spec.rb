require "rails_spec_helper"

feature "viewing submissions" do
  let(:assignment) { create :assignment, accepts_submissions: true, course: membership.course }
  let!(:submission) do
    create :submission, course: membership.course, assignment: assignment, student: student
  end
  let(:student) { create :user }

  context "as a student" do
    let(:membership) { create :course_membership, :student, user: student }

    before { login_as student }

    scenario "allows an editable submission if it's before the due date" do
      visit assignment_path assignment

      expect(find_link("Edit Submission")).to be_visible
    end

    scenario "displays a resubmitted alert for a resubmitted submission" do
      create :grade, submission: submission, assignment: assignment,
        student: student, raw_points: 10000, status: "Released",
        graded_at: DateTime.now
      submission.update_attributes link: "http://example.org",
        submitted_at: DateTime.now
      visit assignment_path assignment

      within ".pageContent" do
        expect(page).to have_content "Resubmitted!"
      end
    end
  end

  context "as a professor" do
    let(:membership) { create :course_membership, :professor, user: professor }
    let(:professor) { create :user }

    before do
      login_as professor
      grade = create :grade, submission: submission, assignment: assignment,
        student: student, raw_points: 10000, status: "Released",
        graded_at: DateTime.now
      submission.update_attributes link: "http://example.org",
        submitted_at: DateTime.now
      visit assignment_submission_path assignment, submission
    end

    scenario "displays a resubmitted alert for a resubmitted submission" do
      within ".pageContent" do
        expect(page).to have_content "Resubmitted!"
      end
    end

    scenario "links open new tabs if they are external" do
      within ".pageContent" do
        expect(page).to have_link("http://example.org", href: "http://example.org")
        expect(find_link("http://example.org")[:target]).to eq "_blank"
      end
    end
  end
end
