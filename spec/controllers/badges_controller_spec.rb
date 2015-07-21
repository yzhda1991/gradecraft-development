#spec/controllers/badges_spec.rb
require 'spec_helper'

describe BadgesController do
	context "as professor" do 
		describe "GET index"

		describe "GET show"

		describe "GET new"

		describe "GET edit"

		describe "POST create"

		describe "POST update"

		describe "GET sort"

		describe "GET destroy"

	end

	context "as student" do 

		describe "protected routes" do
      [
        :index,
        :new,
        :create,
        :sort

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
          (get route, {:id => "1"}).should redirect_to(:root)
        end
      end
    end

	end
end