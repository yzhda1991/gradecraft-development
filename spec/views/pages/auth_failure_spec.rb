# encoding: utf-8
require 'spec_helper'

describe "pages/auth_failure" do

  it "renders successfully" do
    render
    assert_select "h3", text: "Uh Oh!", :count => 1
  end

end
