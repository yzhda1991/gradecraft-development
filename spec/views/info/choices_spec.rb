# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "info/choices" do

  before(:all) do
    clean_models
    @course = create(:course)
    @student_1 = create(:user)
    @student_2 = create(:user)
    @course.students <<[@user_1, @user_2]
    @students = @course.students

    @assignment_type_1 = create(:assignment_type, course: @course)
    @assignment_type_2 = create(:assignment_type, course: @course)
    @course.assignment_types << [@assignment_type_1, @assignment_type_2]
    @assignment_types = @course.assignment_types
  end

  before(:each) do
    assign(:title, "Multiplier Choices")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Multiplier Choices", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 2
    end
  end
end
