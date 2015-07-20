#spec/controllers/staff_controller_spec.rb
require 'spec_helper'

describe StaffController do

	context "as a professor" do 
		describe "GET index"
		describe "GET show"
	end

	context "as a student" do 
		describe "protected routes" do
      [
        :index
      ].each do |route|
          it "#{route} redirects to root" do
      			pending
            (get route).should redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :show
      ].each do |route|
        it "#{route} redirects to root" do
          (get route, {:id => "1"}).should redirect_to(:root)
        end
      end
    end

	end
end