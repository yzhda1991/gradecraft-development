# encoding: utf-8
require "spec_helper"
include CourseTerms

describe "assignments/individual/_table_body" do
  let(:presenter) { Assignments::Presenter.new({ assignment: @assignment,
                                                 course: @course }) }

  before(:each) do
    @course = create(:course)
    @assignment_type = create(:assignment_type)
    @assignment = create(:assignment, assignment_type: @assignment_type)
    @course.assignments << @assignment
    student = create(:user, courses: [@course], role: :student)
    @grade = create(:grade, course: @course, assignment: @assignment,
                    student: student)
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:presenter).and_return presenter
  end

  it "renders successfully" do
    render
  end

  describe "with a graded grade" do
    before(:each) do
      @grade.update(status: "Graded", instructor_modified: true)
    end

    describe "with a score" do
      context "and the grade is present and instructor modified" do
        it "renders the final score" do
          @grade.update(raw_points: @assignment.full_points)
          allow(@grade).to receive(:present?) {true}
          allow(@grade).to receive(:instructor_modified) {true}
          render
          assert_select "td.status-or-score", text: "#{points @grade.final_points}"
        end
      end

      context "and the grade is not present" do
        it "doesn't render the raw score" do
          @grade.update(raw_points: @assignment.full_points)
          allow(@grade).to receive(:present?) {false}
          allow(@grade).to receive(:instructor_modified) {true}
          render
          assert_select "td.status-or-score", text: "#{points @grade.final_points}"
        end
      end

      context "and the grade is not instructor modified" do
        it "doesn't render the raw score" do
          @grade.update(raw_points: @assignment.full_points)
          allow(@grade).to receive(:present?) {true}
          allow(@grade).to receive(:instructor_modified) {false}
          render
          assert_select "td.status-or-score", text: "#{points @grade.final_points}"
        end
      end
    end

    describe "with a pass fail assignment type" do
      it "renders pass/fail status" do
        @assignment.update(pass_fail: true)
        @grade.update(pass_fail_status: "Pass")
        render
        assert_select "td", text: @grade.pass_fail_status
      end
    end
  end
end
