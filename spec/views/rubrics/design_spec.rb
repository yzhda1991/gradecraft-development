# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "rubrics/design" do

  before(:all) do
    clean_models
    @course = create(:course)
    @assignment = create(:assignment, course: @course)
    @rubric = create(:rubric, assignment: @assignment)
    @metric_1 = create(:metric, rubric: @rubric)
    @metric_2 = create(:metric, rubric: @rubric)
    @rubric.metrics << [ @metric_1, @metric_2 ]
    @metrics = @rubric.metrics
  end

  before(:each) do
    assign(:title, "Design Rubric for #{@assignment.name}")
    assign(:course_badges, nil)
    assign(:course_badge_count, 0)
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Design Rubric for #{@assignment.name}", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
