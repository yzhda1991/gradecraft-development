# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "submissions/edit" do

  before(:all) do
    clean_models
    @course = create(:course)
    @assignment = create(:assignment, course: @course)
    @student = create(:user, course: @course)
    @submission = create(:submission, course: @course, student: @student, assignment: @assignment)
  end

  before(:each) do
    assign(:title, "Editing #{@student.name}'s Submission")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Editing #{@student.name}'s Submission", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end

