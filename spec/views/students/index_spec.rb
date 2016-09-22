# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "students/index" do

  before(:all) do
    @course = create(:course)
    @student_1 = create(:user)
    @student_2 = create(:user)
    @course.users <<[@student_1, @student_2]
    @students = @course.users
  end

  before(:each) do
    assign(:title, "Student Roster")
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_user).and_return(@student_1)
  end

  it "renders successfully" do
    render
    assert_select "h2", text: "Student Roster", count: 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".breadcrumbs" do
      assert_select "a", count: 3
    end
  end
end
