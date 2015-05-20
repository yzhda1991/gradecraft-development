# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "challenges/index" do

  before(:all) do
    clean_models
    @course = create(:course)
    @challenge_1 = create(:challenge, course: @course)
    @challenge_2 = create(:challenge, course: @course)
    @course.challenges <<[@challenge_1, @challenge_2]
    @challenges = @course.challenges
  end

  before(:each) do
    assign(:title, "Team Challenges")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Team Challenges", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 2
    end
  end
end
