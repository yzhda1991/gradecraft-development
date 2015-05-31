# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "courses/predictor_settings" do

  before(:all) do
    clean_models
    @course = create(:course)
    @assignment_type_1 = create(:assignment_type, course: @course)
    @assignment_type_2 = create(:assignment_type, course: @course)
    @assignment_1 = create(:assignment, course: @course, assignment_type: @assignment_type_1)
    @assignment_2 = create(:assignment, course: @course, assignment_type: @assignment_type_2)
    @course.assignments << [ @assignment_1, @assignment_2]
    @assignments = @course.assignments
  end

  before(:each) do
    assign(:title, 'Grade Predictor Settings')
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Grade Predictor Settings", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 2
    end
  end

end
