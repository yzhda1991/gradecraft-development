# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "events/index" do

  before(:all) do
    clean_models
    @course = create(:course)
    @event_1 = create(:event, course: @course)
    @event_2 = create(:event, course: @course)
    @course.events <<[@event_1, @event_2]
    @events = @course.events
  end

  before(:each) do
    assign(:title, "Calendar Events")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Calendar Events", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 2
    end
  end
end
