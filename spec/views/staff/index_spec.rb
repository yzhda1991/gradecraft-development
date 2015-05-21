# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "staff/index" do

  before(:all) do
    clean_models
    @course = create(:course)
    @staff_1 = create(:user)
    @staff_2 = create(:user)
    @course.users <<[@staff_1, @staff_2]
    @staff = @course.users
  end

  before(:each) do
    assign(:title, "Staff Index")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Staff Index", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 3
    end
  end
end
