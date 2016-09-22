# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "users/import" do

  before(:all) do
    @course = create(:course)
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
  end
end
