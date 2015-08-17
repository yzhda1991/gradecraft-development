# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "students/show" do

  before(:all) do
    clean_models
    @course = create(:course)
    @student = create(:user)
    @student.courses << @course
    @membership = CourseMembership.where(user: @student, course: @course).first.update(score: '100000')
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
    render
    assert_select "h3", :text => "assignments", :count => 1
  end

end
