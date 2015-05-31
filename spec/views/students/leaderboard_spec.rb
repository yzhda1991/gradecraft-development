# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "students/leaderboard" do

  before(:all) do
    clean_models
    @course = create(:course)
    @student_1 = create(:user)
    @student_2 = create(:user)
    @student_3 = create(:user)
    @course.students << [@student_1, @student_2, @student_3]
    @students = @course.students
  end

  before(:each) do
    assign(:title, "Leaderboard")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Leaderboard", count: 1
  end

end
