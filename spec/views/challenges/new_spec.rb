# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "challenges/new" do

  before(:all) do
    clean_models
    @course = create(:course)
    @challenge = Challenge.new
  end

  before(:each) do
    assign(:title, "Create New Challenge")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Create New Challenge", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 3
    end
  end
end
