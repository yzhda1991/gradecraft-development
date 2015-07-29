#spec/controllers/groups_controller_spec.rb
require 'spec_helper'

describe GroupsController do

	context "as professor" do 
		
		before do
      @course = create(:course_accepting_groups)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @group = create(:group, course: @course)
      @student = create(:user)
      @second_student = create(:user)
      @third_student = create(:user)
      @course.students << [@student, @second_student, @third_student]
      @group.students << [@student, @second_student, @third_student]
      @assignment = create(:group_assignment)
      @assignment.groups << @group

      login_user(@professor)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

		describe "GET index" do 
      it "returns groups for the current course" do
        get :index
        assigns(:title).should eq("Groups")
        assigns(:pending_groups).should eq([@group])
        response.should render_template(:index)
      end
    end

		describe "GET show" do 
      it "displays the specified group" do
        get :show, :id => @group.id
        assigns(:title).should eq(@group.name)
        assigns(:group).should eq(@group)
        response.should render_template(:show)
      end
    end

		describe "GET new" do
      it "renders the new group form" do
        get :new
        assigns(:title).should eq("Start a group")
        assigns(:group).should be_a_new(Group)
        response.should render_template(:new)
      end
    end

		describe "GET edit" do
      it "renders the edit group form" do
        get :edit, :id => @group.id
        assigns(:title).should eq("Editing #{@group.name}")
        assigns(:group).should eq(@group)
        response.should render_template(:edit)
      end
    end

		describe "POST create" do
      it "creates the group with valid attributes"  do
      	pending
        params = attributes_for(:group)
        expect{ post :create, :group => params }.to change(Group,:count).by(1)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, group: attributes_for(:group, name: nil) }.to_not change(Group,:count)
      end
    end

		describe "POST update" do
      it "updates the group" do
        params = { name: "new name" }
        post :update, id: @group.id, :group => params
        @group.reload
        response.should redirect_to(group_path(@group))
        @group.name.should eq("new name")
      end
    end

		describe "GET destroy" do
      it "destroys the group" do
        expect{ get :destroy, :id => @group }.to change(Group,:count).by(-1)
      end
    end

		describe "GET review" do  
      it "allows the instructor to review the specified group" do
        get :review, :id => @group.id
        assigns(:title).should eq("Reviewing #{@group.name}")
        assigns(:group).should eq(@group)
        response.should render_template(:review)
      end
		end

	end

	context "as student" do

		pending

		before do
      @course = create(:course_accepting_groups)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @group = create(:group, course: @course)
      @student = create(:user)
      @second_student = create(:user)
      @third_student = create(:user)
      @student.courses << @course
      @second_student.courses << @course
      @third_student.courses << @course
      @group.students << [@student, @second_student, @third_student]
      @assignment = create(:group_assignment)
      @assignment.groups << @group

      login_user(@student)
      session[:course_id] = @course.id
    end

		describe "GET new" do
      it "renders the new group form" do
        get :new
        assigns(:id => @student.id)
        assigns(:title).should eq("Start a group")
        assigns(:group).should be_a_new(Group)
        response.should render_template(:new)
      end
    end

		describe "POST create" do
      pending
		end

		describe "GET edit" do
      it "renders the edit group form" do
        get :edit, :id => @group.id
        assigns(:title).should eq("Editing #{@group.name}")
        assigns(:group).should eq(@group)
        response.should render_template(:edit)
      end
    end

		describe "POST update" do 
      pending
		end

		describe "GET show" do 
      it "displays the specified group" do
        get :show, :id => @group.id
        assigns(:title).should eq(@group.name)
        assigns(:group).should eq(@group)
        response.should render_template(:show)
      end
    end

		describe "protected routes" do
      [
        :index,
        :review
      ].each do |route|
          it "#{route} redirects to root" do
          	assigns(:id => @student.id)
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