# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "info/resubmissions" do

  before(:all) do
    clean_models
    @course = create(:course)
    @user_1 = create(:user)
    @user_2 = create(:user)
    @course.users << [ @user_1, @user_2 ]
    @students = @course.users

    @team_1 = create(:team, course: @course)
    @team_2 = create(:team, course: @course)
    @course.teams << [ @team_1, @team_2]
    @teams = @course.teams

    @assignment_1 = create(:assignment, course: @course)
    @assignment_2 = create(:assignment, course: @course)
    @submission_1 = create(:submission, assignment: @assignment_1, course: @course, student: @user_1)
    @submission_2 = create(:submission, assignment: @assignment_2, course: @course, student: @user_2)
    @course.submissions << [ @submission_1, @submission_2 ]
    @resubmissions = @course.submissions
  end

  before(:each) do
    view.stub(:current_course).and_return(@course)
    assign(:title, "Resubmitted Assignments")
    assign(:resubmission_count, 2)
    assign(:score, 100)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Resubmitted Assignments", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 2
    end
  end
end
