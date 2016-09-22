# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "staff/show" do

  before(:all) do
    @course = create(:course)
    @staff_member = create(:user)
    @course.users << @staff_member
    @grade_1 = create(:grade)
    @grade_2 = create(:grade)
    @course.grades << [@grade_1, @grade_2]
    @grades = @course.grades
  end

  before(:each) do
    assign(:title, "#{@staff_member.name}")
    allow(view).to receive(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h2", text: "#{@staff_member.name}", count: 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".breadcrumbs" do
      assert_select "a", count: 3
    end
  end
end
