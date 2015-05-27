# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "analytics/teams" do

  before(:all) do
    clean_models
    @course = create(:course)
  end

  before(:each) do
    assign(:title, "Team Analytics")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Team Analytics", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 2
    end
  end
end
