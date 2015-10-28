require 'rails_spec_helper'

describe GroupsController do
  before(:all) { @course = create(:course_accepting_groups) }
  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
    end
    before do
      @group = create(:group, course: @course)
      login_user(@professor)
    end

    describe "GET index" do
      it "returns groups for the current course" do
        get :index
        expect(assigns(:title)).to eq("Groups")
        expect(assigns(:pending_groups)).to eq([@group])
        expect(response).to render_template(:index)
      end
    end

    describe "GET show" do
      it "displays the specified group" do
        get :show, :id => @group.id
        expect(assigns(:title)).to eq(@group.name)
        expect(assigns(:group)).to eq(@group)
        expect(response).to render_template(:show)
      end
    end

    describe "GET new" do
      it "renders the new group form" do
        get :new
        expect(assigns(:title)).to eq("Start a group")
        expect(assigns(:group)).to be_a_new(Group)
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "renders the edit group form" do
        get :edit, :id => @group.id
        expect(assigns(:title)).to eq("Editing #{@group.name}")
        expect(assigns(:group)).to eq(@group)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST create" do
      it "creates the group with valid attributes" do
        skip "implement"
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
        expect(response).to redirect_to(group_path(@group))
        expect(@group.reload.name).to eq("new name")
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
        expect(assigns(:title)).to eq("Reviewing #{@group.name}")
        expect(assigns(:group)).to eq(@group)
        expect(response).to render_template(:review)
      end
    end
  end

  context "as student" do
    before(:all) do
      @student = create(:user)
      @student.courses << @course
    end
    before do
      @group = create(:group, course: @course)
      login_user(@student)
    end

    describe "GET new" do
      it "renders the new group form" do
        get :new
        assigns(:id => @student.id)
        expect(assigns(:title)).to eq("Start a group")
        expect(assigns(:group)).to be_a_new(Group)
        expect(response).to render_template(:new)
      end
    end

    describe "POST create" do
      it "creates the group with valid attributes"  do
        skip "implement"
        params = { name: "name" }
        post :create, :group => params
        expect{ post :create, :group => params }.to change(Group,:count).by(1)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, group: attributes_for(:group, name: nil) }.to_not change(Group,:count)
      end
    end

    describe "GET edit" do
      it "renders the edit group form" do
        get :edit, :id => @group.id
        expect(assigns(:title)).to eq("Editing #{@group.name}")
        expect(assigns(:group)).to eq(@group)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST update" do
      it "updates the group" do
        params = { name: "new name" }
        post :update, id: @group.id, :group => params
        @group.reload
        expect(response).to redirect_to(group_path(@group))
        expect(@group.name).to eq("new name")
      end
    end

    describe "GET show" do
      it "displays the specified group" do
        get :show, :id => @group.id
        expect(assigns(:title)).to eq(@group.name)
        expect(assigns(:group)).to eq(@group)
        expect(response).to render_template(:show)
      end
    end

    describe "protected routes" do
      [
        :index,
        :review
      ].each do |route|
          it "#{route} redirects to root" do
            assigns(:id => @student.id)
            expect(get route).to redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, {:id => "1"}).to redirect_to(:root)
        end
      end
    end
  end
end
