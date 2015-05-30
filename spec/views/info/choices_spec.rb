# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "info/choices" do

  before(:all) do
    clean_models
    @course = create(:course)
    @student_1 = create(:user, course: @course)
    @student_2 = create(:user, course: @course)
    @course.users <<[@user_1, @user_2]
    @students = @course.users
  end

  before(:each) do
    assign(:title, "Multiplier Choices")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Multiplier Choices", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 2
    end
  end
end
