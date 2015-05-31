# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "challenge_grades/mass_edit" do

  before(:all) do
    clean_models
    @course = create(:course)
    @challenge = create(:challenge, course: @course)
    @challenge_grade_1 = create(:challenge_grade, challenge: @challenge)
    @challenge_grade_2 = create(:challenge_grade, challenge: @challenge)
    @challenge.challenge_grades << [ @challenge_grade_1, @challenge_grade_2]
    @challenge_grades = @challenge.challenge_grades
  end

  before(:each) do
    assign(:title, "Editing Challenge Grade")
    view.stub(:current_course).and_return(@course)
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
