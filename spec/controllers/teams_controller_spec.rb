#spec/controllers/teams_controller_spec.rb
require 'spec_helper'

describe TeamsController do

	context "as a professor" do 
		describe "GET index"
		describe "GET new"
		describe "GET edit"
		describe "GET create"
		describe "GET show"
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
            (get route).should redirect_to(:root)
          end
        end
    end


    describe "protected routes requiring id in params" do
      [
        :edit,
        :show,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          (get route, {:id => "10"}).should redirect_to(:root)
        end
      end
    end

	end
end