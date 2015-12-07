# encoding: utf-8
require 'rails_spec_helper'
include CourseTerms

describe "challenge_grades/edit" do

  before(:all) do
    @course = create(:course)
    @challenge = create(:challenge, course: @course)
    @challenge_grade = create(:challenge_grade, challenge: @challenge)
    @team = create(:team, course: @course)
  end

  before(:each) do
    assign(:title, "Editing Challenge Grade")
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:team).and_return(@team)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Editing Challenge Grade", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
