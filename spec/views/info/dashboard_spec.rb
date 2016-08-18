# encoding: utf-8
require "rails_spec_helper"

describe "info/dashboard" do

  let(:view_context) { double(:view_context, current_user: @student_1) }
  let(:presenter) { Info::DashboardCoursePlannerPresenter.new({
    student: @student_1,
    assignments: @assignments,
    course: @course,
    view_context: view_context
  })}

  before(:all) do
    @course = create(:course)
    @professor = create(:user)
    @professor.courses << @course
    @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")

    @assignment_type = create(:assignment_type, course: @course)
    @assignment = create(:assignment, assignment_type: @assignment_type)
    @course.assignments << @assignment

    @grade_scheme_element_1 = create(:grade_scheme_element, course: @course)
    @grade_scheme_element_2 = create(:grade_scheme_element_high, course: @course)
    @grade_scheme_element_3 = create(:grade_scheme_element_low, course: @course)
    @grade_scheme_elements = @course.grade_scheme_elements
    @assignment_type = create(:assignment_type, course: @course)
    @assignment_1 = create(:assignment, course: @course, assignment_type: @assignment_type)
    @assignment_2 = create(:assignment, course: @course, assignment_type: @assignment_type)
    @course.assignments <<[@assignment_1, @assignment_2]
    @assignments = @course.assignments

    @student_1 = create(:user)
    @student_2 = create(:user)
    @student_1.courses << @course

    @membership_2 = CourseMembership.where(user: @student_1, course: @course).first.update(role: "student")

    @gsi = create(:user)
    @gsi.courses << @course
    @membership_3 = CourseMembership.where(user: @gsi, course: @course).first.update(role: "gsi")
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_student).and_return(@student_1)
    allow(view).to receive(:presenter).and_return presenter
  end

  context "as a professor" do

    it "shows the dashboard" do
      allow(view).to receive(:current_user).and_return(@professor)
      render
      assert_select "%h3.pagetitle Dashboard", count: 1
    end

  end

  context "as a student" do

    it "shows the dashboard" do
      allow(view).to receive(:current_user).and_return(@student_1)
      render
      assert_select "#student-dashboard", count: 1
    end

  end

  context "as a GSI" do

    it "shows the dashboard" do
      allow(view).to receive(:current_user).and_return(@gsi)
      render
      assert_select "%h3.pagetitle Dashboard", count: 1
    end

  end

end
