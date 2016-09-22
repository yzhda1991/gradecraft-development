# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "info/per_assign" do

  before(:all) do
    @course = create(:course)
    @assignment_type_1 = create(:assignment_type, course: @course)
    @assignment_type_2 = create(:assignment_type, course: @course)
    @course.assignment_types << [@assignment_type_1, @assignment_type_2]
    @assignment_types = @course.assignment_types
  end

  before(:each) do
    assign(:title, "Assignment Analytics")
    allow(view).to receive(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h2", text: "Assignment Analytics", count: 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".breadcrumbs" do
      assert_select "a", count: 2
    end
  end
end
