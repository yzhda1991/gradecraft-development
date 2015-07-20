#spec/controllers/groups_controller_spec.rb
require 'spec_helper'

describe GroupsController do

	context "as professor" do 
		
		describe "GET index"

		describe "GET new"

		describe "GET create"

		describe "GET edit"

		describe "GET update"

		describe "GET destroy"

		describe "GET review"

		describe "GET show"

	end

	context "as student" do

		describe "GET new"

		describe "GET create"

		describe "GET edit"

		describe "GET update"

		describe "GET show"

		describe "protected routes" do
      [
        :index,
        :review
      ].each do |route|
          it "#{route} redirects to root" do
            (get route).should redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          (get route, {:id => "1"}).should redirect_to(:root)
        end
      end
		end
	end
end