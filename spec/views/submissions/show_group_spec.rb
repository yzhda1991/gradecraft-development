require "rails_spec_helper"
include CourseTerms

describe "submissions/show" do

  let(:presenter) do
    Submissions::ShowPresenter.new(
      course: course,
      id: submission.id,
      assignment_id: assignment.id,
      group_id: group.id,
      view_context: view_context
    )
  end

  let(:view_context) { double(:view_context, points: "12,000") }
  let(:course) { create(:course) }
  let(:assignment) { build(:group_assignment, course: course) }
  let(:group) { create(:group, course: course) }
  let(:submission) { create(:group_submission, course: course, assignment: assignment, group: group) }
  let(:student) { create(:course_membership, :student, course: course).user }

  before do
    allow(view).to receive_messages(
      current_course: course,
      current_user: student,
      # stub path called in partial app/views/submissions/_buttons.haml
      assignment_submission_path: "#",
      presenter: presenter
    )
    group.assignments << assignment
    allow(view).to receive(:current_student).and_return(group.students.first)
  end

  it "renders successfully for a group submission" do
    render
  end

  it "renders the submitted at date" do
    render
    assert_select "span.submission-date", text: "#{ submission.submitted_at }", count: 1
  end
end
