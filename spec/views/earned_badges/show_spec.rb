# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "earned_badges/show" do

  before(:all) do
    clean_models
    @course = create(:course)
    @badge = create(:badge, course: @course)
    @student = create(:user)
    @course.users << @student
    @earned_badge = create(:earned_badge, badge: @badge, student: @student, course: @course)
  end

  before(:each) do
    view.stub(:current_course).and_return(@course)
    assign(:title, "#{@student.name}'s #{@badge.name} Badge")
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "#{@student.name}'s #{@badge.name} Badge", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
