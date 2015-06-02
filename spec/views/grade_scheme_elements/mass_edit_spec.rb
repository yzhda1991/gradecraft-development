# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "grade_scheme_elements/mass_edit" do

  before(:all) do
    clean_models
    @course = create(:course)
    @grade_scheme_element_1 = create(:grade_scheme_element_low, course: @course)
    @grade_scheme_element_2 = create(:grade_scheme_element_high, course: @course)
    @course.grade_scheme_elements <<[@grade_scheme_element_1, @grade_scheme_element_2]
    @grade_scheme_elements = @course.grade_scheme_elements
  end

  before(:each) do
    assign(:title, "Edit Grading Scheme")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Edit Grading Scheme", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
