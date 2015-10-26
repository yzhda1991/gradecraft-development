require 'spec_helper'

describe MetricsController do
  before(:all) { @course = create(:course) }
  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as a student" do
    before(:all) do
      @student = create(:user)
      @student.courses << @course
    end
    before(:each) { login_user(@student) }

    describe "protected routes" do
      [
        :new,
        :create,
        :update_order
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route).to redirect_to(:root)
        end
      end
    end

    describe "protected routes requiring id parameter" do
      [
        :destroy,
        :update
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, id: 1).to redirect_to(:root)
        end
      end
    end
  end
end
