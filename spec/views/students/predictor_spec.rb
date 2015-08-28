# encoding: utf-8
require 'spec_helper'

describe "students/predictor" do

  before(:each) do
    @course = create(:course)
    @student = create(:user)
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_student).and_return(@student)
    allow(@student).to receive(:cached_score_for_course).and_return(0)
  end

  describe "as student" do
    before(:each) do
      allow(view).to receive(:current_user_is_staff?).and_return(false)
      allow(view).to receive(:current_user_is_student?).and_return(true)
    end

    it "renders successfully" do
      render
    end
  end

  describe "as staff" do
    before(:each) do
      allow(view).to receive(:current_user_is_staff?).and_return(true)
      allow(view).to receive(:term_for).and_return("")
    end

    it "renders successfully" do
      render
    end
  end
end
