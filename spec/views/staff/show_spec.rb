# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "staff/show" do

  before(:all) do
    clean_models
    @course = create(:course)
    @staff = create(:user)
    @course.users << @staff
    @grade_1 = create(:grade)
    @grade_2 = create(:grade)
    @course.grades << [@grade_1, @grade_2]
    @grades = @course.grades
  end

  before(:each) do
    assign(:title, "#{@staff.name}")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "#{@staff.name}", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 3
    end
  end
end
