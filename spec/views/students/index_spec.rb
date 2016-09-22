# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "students/index" do

  before(:all) do
    @course = create(:course)
    @student_1 = create(:user)
    @student_2 = create(:user)
    @course.users <<[@student_1, @student_2]
    @students = @course.users
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_user).and_return(@student_1)
  end

  it "renders successfully" do
    render
  end
end
