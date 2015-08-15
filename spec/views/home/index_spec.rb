# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "home/index" do

  it "renders successfully" do
    render
    assert_select ".video-promo", :count => 1
  end

end
