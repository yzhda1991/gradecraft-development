# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "assignment_types/all_grades" do

  before(:all) do
    clean_models
    @course = create(:course)
    @assignment_type_1 = create(:assignment_type, course: @course)
    @assignment_type_2 = create(:assignment_type, course: @course)
    @course.assignment_types <<[@assignment_type_1, @assignment_type_2]
  end

  before(:each) do
    assign(:title, "#{@assignment_type_1.name} Grade Patterns")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "#{@assignment_type_1.name} Grade Patterns", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
