require 'spec_helper'
require 'capybara/rspec'

describe "assignments/new" do

  before(:all) do
    @course = create(:course)
    @assignment = create(:assignment)
  end

  before(:each) do
    assign(:title, "New Assignment")
    assign(:assignment, @assignment)
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:term_for).and_return("Assignment")
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "New Assignment", :count => 1
  end

  describe "pass-fail options", :type => :feature do
    it "hides the points field when pass-fail is activated" do
      skip "get login to work in order to visit page"
      visit(syllabus_path)
      find("pass-fail-toggle").click
      expect(page).to have_selector(".pass-fail-contingent", visible: false)
    end
  end
end
