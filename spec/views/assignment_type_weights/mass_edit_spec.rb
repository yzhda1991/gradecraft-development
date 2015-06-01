# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "assignment_type_weights/mass_edit" do

  before(:all) do
    clean_models
    @course = create(:course)
    @assignment_type_1 = create(:assignment_type, course: @course)
    @assignment_type_2 = create(:assignment_type, course: @course)
    @course.assignment_types << [@assignment_type_1, @assignment_type_2]
    @assignment_types = @course.assignment_types
    @student = create(:user)
    @course.users << [@student]

    @form = AssignmentTypeWeightForm.new(@student, @course)
  end

  before(:each) do
    view.stub(:current_student).and_return(@student)
    view.stub(:current_course).and_return(@course)
    assign(:title, "Editing #{@student.name}'s Kapital")
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Editing #{@student.name}'s Kapital", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
