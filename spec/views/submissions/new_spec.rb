# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "submissions/new" do

  before(:all) do
    clean_models
    @course = create(:course)
    @assignment = create(:assignment, course: @course)
    @submission = Submission.new
  end

  before(:each) do
    assign(:title, "Submit #{@assignment.name} (#{@assignment.point_total})")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Submit #{@assignment.name} (#{@assignment.point_total})", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
