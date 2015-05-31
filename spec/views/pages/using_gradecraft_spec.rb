# encoding: utf-8
require 'spec_helper'

describe "pages/using_gradecraft" do

  it "renders successfully" do
    render
    assert_select "h3", text: "Using Gradecraft", :count => 1
  end

end
