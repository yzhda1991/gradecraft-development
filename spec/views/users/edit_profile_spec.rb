# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "users/edit_profile" do

  before(:all) do
    @course = create(:course)
    @user = create(:user)
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_user).and_return(@user)
  end

  it "renders successfully" do
    render
  end
end
