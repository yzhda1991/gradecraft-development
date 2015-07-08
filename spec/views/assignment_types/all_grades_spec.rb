# encoding: utf-8
require 'spec_helper'

describe "assignment_types/all_grades" do

  before(:all) do
    @course = create(:course)
    @assignment_type = create(:assignment_type)
    @course.assignment_types << [@assignment_type]
    @student_1 = create(:user)
    @student_2 = create(:user)
    @course.students << [@student_1, @student_2]
    @students = @course.students
  end

  before(:each) do
    assign(:assignment_type, @assignment_type)  
    assign(:title, "#{@assignment_type.name} Grade Patterns")
    view.stub(:current_course).and_return(@course)
    view.stub(:term_for).and_return("Assignment")
  end

  describe "as faculty" do

    it "renders successfully" do
      view.stub(:current_user_is_staff?).and_return(true)
      render
      assert_select "h3", :count => 1
    end

    it "renders the breadcrumbs" do
      view.stub(:current_user_is_staff?).and_return(true)
      render
      assert_select ".content-nav", :count => 1
      assert_select ".breadcrumbs" do
        assert_select "a", :count => 4
      end
    end

  end
end
