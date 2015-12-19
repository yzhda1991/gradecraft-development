require 'rails_spec_helper'
include CourseTerms

describe "submissions/show" do

  let(:presenter) { ShowSubmissionPresenter.new({ course: @course, id: @submission.id, assignment_id: @assignment.id, view_context: view_context }) }
  let(:view_context) { double(:view_context, points: "12,000") }

  before(:all) do
    @course = create(:course)
    @assignment = create(:assignment, course: @course)
    @student = create(:user)
    @course.users << @student
    @submission = create(:submission, course: @course, assignment: @assignment, student: @student)
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
    # stub path called in partial app/views/submissions/_buttons.haml
    allow(view).to receive(:assignment_submission_path).and_return("#")
    allow(view).to receive(:presenter).and_return presenter
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "#{@student.first_name}'s #{@assignment.name} Submission (12,000 points)", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
