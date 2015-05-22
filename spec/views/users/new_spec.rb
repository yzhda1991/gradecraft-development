# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "users/new" do

  before(:all) do
    clean_models
    @course = create(:course)
    @user = User.new
  end

  before(:each) do
    assign(:title, "Create a New User")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Create a New User", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 3
    end
  end
end
