# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "students/grading_scheme" do

  before(:all) do
    @course = create(:course)
    @student = create(:user)
    @student.courses << @course
    @grade_scheme_element_1 = create(:grade_scheme_element_low, course: @course)
    @grade_scheme_element_2 = create(:grade_scheme_element_high, course: @course)
    @course.grade_scheme_elements <<[@grade_scheme_element_1, @grade_scheme_element_2]
    @grade_scheme_elements = @course.grade_scheme_elements
    @membership = CourseMembership.where(user: @student, course: @course)
      .first.update(score: "10000")
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_student).and_return(@student)
  end

  it "renders successfully" do
    render
    assert_select "span", text: "Your rank:", count: 1
  end

end
