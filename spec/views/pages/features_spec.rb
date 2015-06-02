# encoding: utf-8
require 'spec_helper'

describe "pages/features" do

  it "renders successfully" do
    render
    assert_select "h3", text: "GradeCraft Features #{Date.today.year}", :count => 1
  end

end
