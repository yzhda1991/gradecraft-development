# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "students/index" do

  before(:all) do
    clean_models
    @course = create(:course)
    @student_1 = create(:user)
    @student_2 = create(:user)
    @course.users <<[@student_1, @student_2]
    @students = @course.users
  end

  before(:each) do
    assign(:title, "Student Roster")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Student Roster", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 3
    end
  end
end
