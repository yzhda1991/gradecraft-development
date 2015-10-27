# encoding: utf-8
require 'rails_spec_helper'

describe "assignments/settings" do

  before(:all) do
    @course = create(:course)
    @assignment = create(:assignment)
  end

  before(:each) do
    assign(:title, "Assignment")
    assign(:assignments, [@assignment])
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:term_for).and_return("Assignment")
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Assignment", :count => 1
  end
end
