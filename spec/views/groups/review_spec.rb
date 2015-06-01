# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "groups/review" do

  before(:all) do
    clean_models
    @course = create(:course)
    @group = create(:group, course: @course)
  end

  before(:each) do
    assign(:title, "Reviewing #{@group.name}")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Reviewing #{@group.name}", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
