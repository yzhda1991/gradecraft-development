# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "analytics/top_10" do

  before(:all) do
    clean_models
    @course = create(:course)
    @student_1 = create(:user)
    @student_2 = create(:user)
    @student_3 = create(:user)
    @student_4 = create(:user)
    @student_5 = create(:user)
    @student_6 = create(:user)
    @student_7 = create(:user)
    @student_8 = create(:user)
    @student_9 = create(:user)
    @student_10 = create(:user)
    @course.users << [@student_1, @student_2, @student_3, @student_4, @student_5, @student_6, @student_7, @student_8, @student_9, @student_10]
    @top_ten_students = @course.users

    @student_11 = create(:user)
    @student_12 = create(:user)
    @student_13 = create(:user)
    @student_14 = create(:user)
    @student_15 = create(:user)
    @student_16 = create(:user)
    @student_17 = create(:user)
    @student_18 = create(:user)
    @student_19 = create(:user)
    @student_20 = create(:user)
    @course.users << [@student_11, @student_12, @student_13, @student_14, @student_15, @student_16, @student_17, @student_18, @student_19, @student_20]
    @bottom_ten_students = @course.users

  end

  before(:each) do
    assign(:title, "Top 10/Bottom 10")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Top 10/Bottom 10", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 2
    end
  end
end
