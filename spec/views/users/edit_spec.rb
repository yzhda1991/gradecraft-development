# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "users/edit" do

  before(:all) do
    clean_models
    @course = create(:course)
    @user = create(:user)
    @course.users << @user
  end

  before(:each) do
    assign(:title, "Editing #{@user.name}")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Editing #{@user.name}", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end

