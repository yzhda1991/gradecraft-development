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
    assign(:title, "Editing #{@user.name}")
    allow(view).to receive(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h2", text: "Editing #{@user.name}", count: 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".breadcrumbs" do
      assert_select "a", count: 4
    end
  end
end
