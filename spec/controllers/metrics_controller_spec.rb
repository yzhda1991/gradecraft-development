#spec/controllers/metrics_controller_spec.rb
require 'spec_helper'

describe MetricsController do

	context "as a professor" do 

		describe "GET new"
		describe "GET create"
		describe "GET destroy"
		describe "GET update"
		describe "GET update_order"

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