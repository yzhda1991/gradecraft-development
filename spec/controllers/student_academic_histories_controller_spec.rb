require 'rails_spec_helper'

describe StudentAcademicHistoriesController, focus: true do
  before(:all) do
    @course = create(:course)
    @student = create(:user)
    CourseMembership.create user: @student, course: @course, role: "student"
    @academic_history = create(:student_academic_history, student: @student, course: @course)
  end

  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as a professor" do 
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
    end
    before(:each) { login_user(@professor) }

    describe "GET index" do
      it "returns all academic histories for the current course" do
        get :index
        expect(assigns(:academic_histories)).to eq([@academic_history])
        expect(response).to render_template(:index)
      end
    end

    describe "GET show" do 
      it "displays a single student's academic history for this course" do 
        get :show, {:id => @student.id}
        expect(assigns(:student)).to eq(@student)
        expect(response).to render_template(:show)
      end
    end

    describe "GET new" do 
      it "displays a form to create a new academic history" do
        @student_2 = create(:user)
        CourseMembership.create user: @student_2, course: @course, role: "student"
        get :new, {:id => @student_2.id}
        expect(assigns(:student)).to eq(@student_2)
        expect(assigns(:academic_history)).to be_a_new(StudentAcademicHistory)
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do 
      it "displays the form to edit a student's academic history" do
        get :edit, {:id => @student.id}
        expect(assigns(:student)).to eq(@student)
        expect(assigns(:academic_history)).to eq(@academic_history)
        expect(response).to render_template(:edit)
      end
    end

  end

  context "as a student" do
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
        :show,
        :edit,
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
