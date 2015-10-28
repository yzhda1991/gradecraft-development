# encoding: utf-8
require 'rails_spec_helper'
include CourseTerms

describe "courses/show" do

  before(:all) do
    @course = create(:course)
  end

  before(:each) do
    assign(:title, "Course Settings")
    allow(view).to receive(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Course Settings", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 3
    end
  end
end
