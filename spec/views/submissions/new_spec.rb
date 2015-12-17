# encoding: utf-8
require 'rails_spec_helper'
include CourseTerms

describe "submissions/new" do

  let(:presenter) { NewSubmissionPresenter.new({ course: @course, assignment_id: @assignment.id }) }

  before(:all) do
    @course = create(:course)
    @assignment = create(:assignment, course: @course)
    @submission = Submission.new
  end

  before(:each) do
    assign(:title, "Submit #{@assignment.name} (#{@assignment.point_total})")
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:presenter).and_return presenter
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Submit #{@assignment.name} (#{@assignment.point_total})", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
