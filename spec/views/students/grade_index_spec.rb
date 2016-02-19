# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "students/grade_index" do

  before(:all) do
    @course = create(:course)
    @student = create(:user)
    @course.students << @student
    @grade_1 = create(:grade)
    @grade_2 = create(:grade)
    @course.grades << [ @grade_1, @grade_2]
    @grades = @course.grades
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_student).and_return(@student)
  end

  it "renders successfully" do
    render
    assert_select "h3", :count => 1
  end

end
