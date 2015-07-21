#spec/controllers/student_academic_histories_controller_spec.rb
require 'spec_helper'

describe StudentAcademicHistoriesController do
	context "as a professor" do 
		describe "GET index"
		describe "GET show"
		describe "GET new"
		describe "GET create"
		describe "GET edit"
		describe "GET update"
		describe "GET destroy"
	end

	context "as a student" do 
		describe "protected routes" do
      [
        :index,
        :new,
        :create
      ].each do |route|
          it "#{route} redirects to root" do
      			pending
            (get route).should redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :show,
        :edit,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          pending
          (get route, {:id => "1"}).should redirect_to(:root)
        end
      end
    end

	end
end