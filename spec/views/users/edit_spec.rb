# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "users/edit" do

  before(:all) do
    @course = create(:course)
    @user = create(:user)
    @course.users << @user
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
  end
end
