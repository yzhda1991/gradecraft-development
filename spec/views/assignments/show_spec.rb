# encoding: utf-8
require 'spec_helper'

describe "assignments/show" do
  let(:presenter) { AssignmentPresenter.new(@assignment) }

  before(:each) do
    @course = create(:course)
    @assignment_type = create(:assignment_type, course: @course, max_points: 1000)
    @assignment = create(:assignment, :assignment_type => @assignment_type)
    @course.assignments << @assignment
    @student = create(:user)
    @student.courses << @course
    assign(:assignment, @assignment)
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_student).and_return(@student)
    allow(view).to receive(:presenter).and_return presenter
  end

  describe "as student" do

    before(:each) do
      allow(view).to receive(:current_user).and_return(@student)
    end

    it "renders the assignment grades" do
      render
      assert_select "h3", :count => 1
    end

    describe "pass fail assignment" do
      it "renders pass/fail instead of the points possible in the guidelines" do
        @assignment.update(pass_fail: true)
        render
        assert_select ("div.italic"), text: "Pass/Fail Assignment"
      end
    end
  end
end
