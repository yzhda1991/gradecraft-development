# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "students/teams" do

  before(:all) do
    @course = create(:course)
    @student = create(:user)
    @team = create(:team, course: @course)
    @student.courses << @course
    @membership = CourseMembership.where(user: @student, course: @course).first.update(score: "100000")
    @teams = @course.teams
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_student).and_return(@student)
  end

  it "renders successfully" do
    render
    assert_select "#leaderboardBarChart", count: 1
  end

end
