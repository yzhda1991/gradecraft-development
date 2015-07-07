# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "students/show" do

  before(:all) do
    clean_models
    @course = create(:course)
    @student = create(:user)
    @course.students << @student
    @assignment_type_1 = create(:assignment_type, course: @course)
    @assignment_type_2 = create(:assignment_type, course: @course)
    @course.assignment_types << [@assignment_type_1, @assignment_type_2]
    @assignment_types = @course.assignment_types

    @assignment_1 = create(:assignment, course: @course)
    @assignment_2 = create(:assignment, course: @course)
    @course.assignments << [@assignment_1, @assignment_2]
    @assignments = @course.assignments
  end

  before(:each) do
    view.stub(:current_course).and_return(@course)
    view.stub(:current_student).and_return(@student)
  end

  it "renders successfully" do
    pending
    render
    assert_select "h4", :count => 1
  end

  it "renders the breadcrumbs" do
    pending
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 3
    end
  end
end
