# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "students/course_progress" do

  before(:all) do
    clean_models
    @course = create(:course)
    @student = create(:user)
    @student.courses << @course
    @grade_scheme_element_1 = create(:grade_scheme_element_low, course: @course)
    @grade_scheme_element_2 = create(:grade_scheme_element_high, course: @course)
    @course.grade_scheme_elements <<[@grade_scheme_element_1, @grade_scheme_element_2]
    @grade_scheme_elements = @course.grade_scheme_elements
    @membership = CourseMembership.where(user: @student, course: @course).first.update(score: '100000')
  end

  before(:each) do
    view.stub(:current_course).and_return(@course)
    view.stub(:current_student).and_return(@student)
  end

  it "renders successfully" do
    render
    assert_select "h3", :count => 1
  end

end
