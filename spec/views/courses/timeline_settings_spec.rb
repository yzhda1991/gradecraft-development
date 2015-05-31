# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "courses/timeline_settings" do

  before(:all) do
    clean_models
    @course = create(:course)

    @assignment_1 = create(:assignment, course: @course)
    @assignment_2 = create(:assignment, course: @course)
    @course.assignments << [ @assignment_1, @assignment_2 ]
    @assignments = @course.assignments

  end

  before(:each) do
    view.stub(:current_course).and_return(@course)
    assign(:title, "Timeline Settings")
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Timeline Settings", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end

end
