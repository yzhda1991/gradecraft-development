#spec/controllers/courses_controller_spec.rb
require 'spec_helper'

describe CoursesController do

	context "as professor" do

    before do
      @course = create(:course)
      @second_course = create(:course)
      @courses = []
      @courses << [@course, @second_course]
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")

      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

		describe "GET index" do
      it "returns all courses" do
        get :index
        assigns(:title).should eq("Course Index")
        assigns(:courses).should eq(Course.all)
        response.should render_template(:index)
      end
    end

		describe "GET show" do
      it "returns the course show page" do
        get :show, :id => @course.id
        assigns(:title).should eq("Course Settings")
        assigns(:course).should eq(@course)
        response.should render_template(:show)
      end
    end

		describe "GET new" do
      it "assigns title" do
        get :new
        assigns(:title).should eq("Create a New Course")
        assigns(:course).should be_a_new(Course)
        response.should render_template(:new)
      end
    end

    describe "GET edit" do
      it "edit title" do
        get :edit, :id => @course.id
        assigns(:title).should eq("Editing Basic Settings")
        assigns(:course).should eq(@course)
        response.should render_template(:edit)
      end
    end

		describe "POST create" do
      it "creates the course with valid attributes"  do
        params = attributes_for(:course)
        params[:id] = @course
        expect{ post :create, :course => params }.to change(Course,:count).by(1)
      end

      it "manages file uploads" do
      	pending
        Course.delete_all
        params = attributes_for(:course)
        params[:course_id] = @course
        params.merge! :course_syllabus_attributes => {"0" => {"file" => [fixture_file('test_file.txt', 'txt')]}}
        post :create, :course => params
        course = Course.where(name: params[:name]).last
        expect course.course_syllabus.count.should eq(1)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, course: attributes_for(:course, name: nil) }.to_not change(Course,:count)
      end
    end

		describe "POST update" do
      it "updates the course" do
        params = { name: "new name" }
        post :update, id: @course.id, :course => params
        @course.reload
        response.should redirect_to(course_path(@course))
        @course.name.should eq("new name")
      end

      it "manages file uploads" do
      	pending
        params = {:course_syllabus_attributes => {"0" => {"file" => [fixture_file('test_file.txt', 'txt')]}}}
        post :update, id: @course.id, :course => params
        expect @course.course_syllabus.count.should eq(1)
      end
    end

		describe "GET destroy" do
      it "destroys the course" do
        expect{ get :destroy, :id => @course }.to change(Course,:count).by(-1)
      end
    end

	end

	context "as student" do

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
          (get route, {:id => "1"}).should redirect_to(:root)
        end
      end
    end

	end

end
