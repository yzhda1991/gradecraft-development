# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "users/index" do

  before(:all) do
    @course = create(:course)
    @user_1 = create(:user)
    @user_2 = create(:user)
    @course.users <<[@user_1, @user_2]
    @users = @course.users
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
  end
end
