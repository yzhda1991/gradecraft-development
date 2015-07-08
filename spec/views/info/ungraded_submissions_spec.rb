# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "info/ungraded_submissions" do

  before(:all) do
    clean_models
    @course = create(:course)
    @assignment_types = [create(:assignment_type, course: @course, max_value: 1000)]
    @assignment = create(:assignment, :assignment_type => @assignment_types[0])
    @student_1 = create(:user)
    @student_2 = create(:user)
    assign(:assignment_types, @assignment_types)
  end

  before(:each) do
    assign(:title, "Ungraded Assignment Submissions")
    view.stub(:current_course).and_return(@course)
    ungraded_submission_1 = create(:submission, student: @student_1, assignment: @assignment)
    ungraded_submission_2 = create(:submission, student: @student_2, assignment: @assignment)
    @ungraded_submissions = @assignment.submissions
  end

  it "renders" do
    render
    assert_select "h3", text: "Ungraded Assignment Submissions", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 2
    end
  end
end
