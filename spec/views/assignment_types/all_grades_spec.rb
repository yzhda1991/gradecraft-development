# encoding: utf-8
require "rails_spec_helper"

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
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:term_for).and_return("Assignment")
  end

  describe "as faculty" do

    it "renders successfully" do
      allow(view).to receive(:current_user_is_staff?).and_return(true)
      render
    end
  end
end
