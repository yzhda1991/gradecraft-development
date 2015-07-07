# encoding: utf-8
require 'spec_helper'

describe "assignments/detailed_grades" do

  before(:all) do
    @course = create(:course)
    @assignment = create(:assignment)
    @course.assignments << [@assignment]
    @student = create(:user)
    @student.courses << @course
  end

  before(:each) do
    assign(:assignment, @assignment)
    assign(:students, [@student])
    view.stub(:current_course).and_return(@course)
    view.stub(:term_for).and_return("Assignment")
    assign(:title, "#{@assignment.name} Detailed Grades (#{ points @assignment.point_total} points)")
  end

  describe "as faculty" do
    it "renders the assignment view" do
      view.stub(:current_user_is_staff?).and_return(true)
      view.stub(:term_for).and_return("Assignment")
      assign(:students, [@student])
      assign(:grades, {@student.id => nil})
      render
      assert_select "h3", :count => 1
    end
  end
end
