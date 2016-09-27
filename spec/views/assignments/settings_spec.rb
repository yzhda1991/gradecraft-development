# encoding: utf-8
require "rails_spec_helper"

describe "assignments/settings" do

  before(:all) do
    @course = create(:course)
    @assignment_types = create(:assignment_type)
  end

  before(:each) do
    assign(:assignment_types, [@assignment_types])
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:term_for).and_return("Assignment")
  end

  it "renders successfully" do
    render
  end
end
