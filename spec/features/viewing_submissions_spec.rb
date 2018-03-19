feature "viewing submissions" do
  let!(:institution) { create :institution }
  let(:course) { create :course, institution: institution }
  let(:assignment) { create :assignment, accepts_submissions: true, course: course }
  let!(:submission) do
    create :submission, course: course, assignment: assignment, student: student
  end
  let(:student) { create :user, courses: [course], role: :student }

  context "as a student" do
    before { login_as student }

    scenario "allows an editable submission if it's before the due date" do
      visit assignment_path assignment

      expect(find_link("Edit Submission", match: :first)).to be_visible
    end

    scenario "displays a resubmitted alert for a resubmitted submission" do
      create :grade, submission: submission, assignment: assignment,
        student: student, raw_points: 10000, student_visible: true,
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
    let(:professor) { create :user, courses: [course], role: :professor }

    before do
      login_as professor
      grade = create :grade, submission: submission, assignment: assignment,
        student: student, raw_points: 10000, student_visible: true,
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
