# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "challenges/show" do

  before(:all) do
    clean_models
    @course = create(:course)
    @challenge = create(:challenge, course: @course)
    @team_1 = create(:team, course: @course)
    @team_2 = create(:team, course: @course)
    @course.teams << [@team_1, @team_2]
    @teams = @course.teams
  end

  before(:each) do
    assign(:title, "{@challenge.name}")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "{@challenge.name}", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 3
    end
  end
end
