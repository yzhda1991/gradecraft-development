# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "staff/index" do

  before(:all) do
    @course = create(:course)
    @staff_1 = create(:user)
    @staff_2 = create(:user)
    @course.users <<[@staff_1, @staff_2]
    @staff = @course.users
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
  end
end
