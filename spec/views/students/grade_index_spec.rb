# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "students/grade_index" do

  before(:all) do
    clean_models
    @course = create(:course)
    @student = create(:user)
    @course.students << @student
    @grade_1 = create(:grade)
    @grade_2 = create(:grade)
    @course.grades << [ @grade_1, @grade_2]
    @grades = @course.grades
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
