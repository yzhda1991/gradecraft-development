# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "analytics/students" do

  before(:all) do
    @course = create(:course)
    @student_1 = create(:user)
    @student_2 = create(:user)
    @course.users <<[@student_1, @student_2]
    @nonpredictors = @course.users
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
  end
end
