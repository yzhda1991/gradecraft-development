# encoding: utf-8
require 'rails_spec_helper'

describe "assignments/criterion_grades_review" do

  let(:presenter) { AssignmentPresenter.new({ assignment: @assignment, course: @course }) }

  before(:all) do
    @course = create(:course)
    @assignment = create(:assignment)
  end

  before(:each) do
    assign(:title, "Assignment")
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:term_for).and_return("Assignment")
    allow(view).to receive(:presenter).and_return presenter
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "#{@assignment.name} Review Rubric Grades (#{ points @assignment.point_total } points)", :count => 1
  end
end
