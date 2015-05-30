# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "courses/predictor_preview" do

  before(:all) do
    clean_models
    @course = create(:course)
  end

  before(:each) do
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Grade Predictor Preview", :count => 1
  end

end
