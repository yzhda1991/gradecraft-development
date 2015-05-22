# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "events/edit" do

  before(:all) do
    clean_models
    @course = create(:course)
    @event = create(:event, course: @course)
  end

  before(:each) do
    assign(:title, "Editing No Class!")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Editing No Class!", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 3
    end
  end
end

