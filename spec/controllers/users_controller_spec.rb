require 'spec_helper'

describe UsersController do

	context "as a professor" do 
		describe "GET index"
		describe "GET new"
		describe "GET edit"
		describe "GET create"
		describe "GET update"
		describe "GET destroy"
		describe "GET edit_profile"
		describe "GET update_profile"
		describe "GET import"
		describe "GET upload"
	end

	context "as a student" do 

		describe "GET edit_profile"
		describe "GET update_profile"

		describe "protected routes" do
      [
        :index,
        :new,
        :create,
        :import,
        :upload
      ].each do |route|
          it "#{route} redirects to root" do
            (get route).should redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :edit,
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
