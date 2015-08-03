#spec/controllers/metrics_controller_spec.rb
require 'spec_helper'

describe MetricsController do

	context "as a professor" do

    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @challenge = create(:challenge, course: @course)
      @course.challenges << @challenge
      @challenges = @course.challenges
      @student = create(:user)
      @student.courses << @course
      @team = create(:team, course: @course)
      @team.students << @student
      @teams = @course.teams

      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

		describe "GET new" do
      pending
    end

		describe "GET create" do
      pending
    end

    describe "GET destroy" do
      it "destroys the metric" do
        pending
        expect{ get :destroy, :id => @metric }.to change(Metric,:count).by(-1)
      end
    end

		describe "GET update" do
      pending
    end

		describe "GET update_order" do
      pending
    end

	end

	context "as a student" do

    describe "protected routes" do
      [
        :new,
        :create,
        :destroy,
        :update,
        :update_order
      ].each do |route|
        it "#{route} redirects to root" do
        	pending
          (get route).should redirect_to(:root)
        end
      end
    end

	end
end
