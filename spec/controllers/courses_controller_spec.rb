require 'spec_helper'

describe CoursesController do
  before(:all) { @course = create(:course) }
  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
    end
    before { login_user(@professor) }

    describe "GET index" do
      it "returns all courses" do
        get :index
        expect(assigns(:title)).to eq("Course Index")
        expect(assigns(:courses)).to eq(Course.all)
        expect(response).to render_template(:index)
      end
    end

    describe "GET show" do
      it "returns the course show page" do
        get :show, :id => @course.id
        expect(assigns(:title)).to eq("Course Settings")
        expect(assigns(:course)).to eq(@course)
        expect(response).to render_template(:show)
      end
    end

    describe "GET new" do
      it "assigns title" do
        get :new
        expect(assigns(:title)).to eq("Create a New Course")
        expect(assigns(:course)).to be_a_new(Course)
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "edit title" do
        get :edit, :id => @course.id
        expect(assigns(:title)).to eq("Editing Basic Settings")
        expect(assigns(:course)).to eq(@course)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST create" do
      it "creates the course with valid attributes"  do
        params = attributes_for(:course)
        params[:id] = @course
        expect{ post :create, :course => params }.to change(Course,:count).by(1)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, course: attributes_for(:course, name: nil) }.to_not change(Course,:count)
      end
    end

    describe "POST update" do
      it "updates the course" do
        params = { name: "new name" }
        post :update, id: @course.id, :course => params
        expect(response).to redirect_to(course_path(@course))
        expect(@course.reload.name).to eq("new name")
      end
    end

    describe "GET destroy" do
      it "destroys the course" do
        expect{ get :destroy, :id => @course }.to change(Course,:count).by(-1)
      end
    end
  end

  context "as student" do
    before(:all) do
      @student = create(:user)
      @student.courses << @course
    end
    before(:each) { login_user(@student) }

    describe "protected routes" do
      [
        :index,
        :new,
        :create
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route).to redirect_to(:root)
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
          expect(get route, {:id => "1"}).to redirect_to(:root)
        end
      end
    end
  end
end
