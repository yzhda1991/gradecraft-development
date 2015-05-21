# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "earned_badges/edit" do

  before(:all) do
    clean_models
    @course = create(:course)
    @badge = create(:badge, course: @course)
    @student = create(:user)
    @earned_badge = create(:earned_badge, course: @course, badge: @badge, student: @student)
  end

  before(:each) do
    assign(:title, "Editing Awarded Achievement")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Editing Awarded Achievement", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
