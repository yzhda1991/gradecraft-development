# TODO: Predictor partials have been replaced with Angular templates.
# take any logic tested in this page and move it to a controller spec, or
# test the json from the predictor_data routes, then remove this file.

# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "students/predictor/_assignments" do

  before(:each) do
    clean_models
    @course = create(:course)
    assignment_types = [create(:assignment_type, course: @course)]
    @assignment = create(:assignment, :assignment_type => assignment_types[0])
    @course.assignments << @assignment
    @student = create(:user)
    @student.courses << @course
    view.stub(:current_course).and_return(@course)
    view.stub(:current_student).and_return(@student)
  end

  describe "with predictable assignments" do
    it "renders successfully" do
      pending "moved to angular templates"
      @course.assignment_types[0].has_predictable_assignments?.should be_true
      render
    end

    describe "when student's score for assignment type is greater than zero" do
      it "renders the points earned" do
        pending "moved to angular templates"
        @grade = create(:scored_grade, assignment: @assignment, student: @student)
        render
        assert_select "div.right.radius.label.success", count: 1
      end
    end

    describe "when student's score for assignment type is zero" do
      it "renders the points possible" do
        pending "moved to angular templates"
        render
        assert_select "div.right.radius.label.fade", count: 1
      end
    end

    describe "with a pass fail assignment" do
      pending "moved to angular templates"

      before(:each) do
        @assignment.update(pass_fail: true)
      end

      it "renders a pass/fail predictor switch defaulting to fail" do
        pending "moved to angular templates"
        render
        assert_select "div.switch-label", text: "Fail", count: 1
        pending "moved to angular templates"
      end

      it "persists a Pass prediction in the pass/fail switch" do
        pending "moved to angular templates"
        @grade = create(:grade, assignment: @assignment, student: @student, predicted_score: 1)
        render
        assert_select "div.switch-label", text: "Pass", count: 1
        pending "moved to angular templates"
      end

      it "uses the course term for Fail when present" do
        pending "moved to angular templates"
        @course.update(fail_term: "No Pass For You!")
        render
        assert_select "div.switch-label", text: "No Pass For You!", count: 1
        pending "moved to angular templates"
      end

      it "uses the course term for Pass when present" do
        pending "moved to angular templates"
        @course.update(pass_term: "Pwned")
        @grade = create(:grade, assignment: @assignment, student: @student, predicted_score: 1)
        render
        assert_select "div.switch-label", text: "Pwned", count: 1
      end
    end
  end
end
