require 'rails_spec_helper'
include CourseTerms

describe "students/predictor/_assignments" do

  before(:each) do
    @course = create(:course)
    assignment_types = [create(:assignment_type, course: @course)]
    @assignment = create(:assignment, :assignment_type => assignment_types[0])
    @course.assignments << @assignment
    @student = create(:user)
    @student.courses << @course
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_student).and_return(@student)
  end

  describe "with predictable assignments" do
    it "renders successfully" do
      skip "moved to angular templates"
      expect(@course.assignment_types[0].has_predictable_assignments?).to be_truthy
      render
    end

    describe "when student's score for assignment type is greater than zero" do
      it "renders the points earned" do
        skip "moved to angular templates"
        @grade = create(:scored_grade, assignment: @assignment, student: @student)
        render
        assert_select "div.right.radius.label.success", count: 1
      end
    end

    describe "when student's score for assignment type is zero" do
      it "renders the points possible" do
        skip "moved to angular templates"
        render
        assert_select "div.right.radius.label.fade", count: 1
      end
    end

    describe "with a pass fail assignment" do
      skip "moved to angular templates"

      before(:each) do
        @assignment.update(pass_fail: true)
      end

      it "renders a pass/fail predictor switch defaulting to fail" do
        skip "moved to angular templates"
        render
        assert_select "div.switch-label", text: "Fail", count: 1
        skip "moved to angular templates"
      end

      it "persists a Pass prediction in the pass/fail switch" do
        skip "moved to angular templates"
        @grade = create(:grade, assignment: @assignment, student: @student, predicted_score: 1)
        render
        assert_select "div.switch-label", text: "Pass", count: 1
        skip "moved to angular templates"
      end

      it "uses the course term for Fail when present" do
        skip "moved to angular templates"
        @course.update(fail_term: "No Pass For You!")
        render
        assert_select "div.switch-label", text: "No Pass For You!", count: 1
        skip "moved to angular templates"
      end

      it "uses the course term for Pass when present" do
        skip "moved to angular templates"
        @course.update(pass_term: "Pwned")
        @grade = create(:grade, assignment: @assignment, student: @student, predicted_score: 1)
        render
        assert_select "div.switch-label", text: "Pwned", count: 1
      end
    end
  end
end
