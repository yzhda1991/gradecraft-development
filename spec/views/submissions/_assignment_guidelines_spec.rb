require "rails_spec_helper"

describe "submissions/_assignment_guidelines" do

  before(:each) do
    course = create(:course)
    @assignment = create(:assignment, course: course)
    allow(view).to receive(:current_course).and_return(course)
    allow(view).to receive(:assignment).and_return @assignment
  end

  describe "with a graded assignment" do
    it "renders Pass/Fail and not the points total" do
      render
      assert_select "p", text: "#{points @assignment.full_points} points possible", count: 1
    end
  end

  describe "with a pass fail assignment"  do
    it "renders Pass/Fail and not the points total" do
      @assignment.update(pass_fail: true)
      render
      assert_select "p", text: "#{points @assignment.full_points} points possible", count: 0
      assert_select "p", text: "Pass/Fail Assignment", count: 1
    end
  end
end
