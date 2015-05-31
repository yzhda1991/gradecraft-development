# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "assignment_types/all_grades" do

  before(:all) do
    clean_models
    @course = create(:course)
    @assignment_type = create(:assignment_type, course: @course)

    @student_1 = create(:user)
    @student_2 = create(:user)
    @course.students << [@student_1, @student_2]
    @students = @course.students

  end

  before(:each) do
    assign(:title, "#{@assignment_type.name} Grade Patterns")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "#{@assignment_type.name} Grade Patterns", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
