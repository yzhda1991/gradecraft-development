# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "submissions/show" do

  before(:all) do
    clean_models
    @course = create(:course)
    @assignment = create(:assignment, course: @course)
    @student = create(:user)
    @course.users << @student
    @submission = create(:submission, course: @course, assignment: @assignment, student: @student)
  end

  before(:each) do
    assign(:title, "#{@student.name}'s #{@assignment.name} Submission (#{@assignment.point_total} points)")
    view.stub(:current_course).and_return(@course)
    # stub path called in partial app/views/submissions/_buttons.haml
    view.stub(:assignment_submission_path).and_return("#")
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "#{@student.name}'s #{@assignment.name} Submission (#{@assignment.point_total} points)", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
