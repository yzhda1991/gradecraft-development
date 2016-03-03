require "rails_spec_helper"

describe StudentAcademicHistoriesController do
  before(:all) do
    @course = create(:course)
    @student = create(:user)
    CourseMembership.create user: @student, course: @course, role: "student"
    @academic_history = create(:student_academic_history, student: @student, course: @course, gpa: 2.2)
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

    describe "GET show" do
      it "displays a single student's academic history for this course" do 
        get :show, {student_id: @student.id, id: @academic_history.id}
        expect(assigns(:student)).to eq(@student)
        expect(response).to render_template(:show)
      end
    end

    describe "GET new" do
      it "displays a form to create a new academic history" do
        get :new, {student_id: @student.id}
        expect(assigns(:student)).to eq(@student)
        expect(assigns(:academic_history)).to be_a_new(StudentAcademicHistory)
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "displays the form to edit a student's academic history" do
        get :edit, {student_id: @student.id, id: @academic_history.id}
        expect(assigns(:student)).to eq(@student)
        expect(assigns(:academic_history)).to eq(@academic_history)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST create" do
      it "creates an academic history with valid attributes" do
        @student_2 = create(:user)
        @student_2.courses << @course
        params = attributes_for(:student_academic_history)
        params[:gpa] = 3
        params[:student_id] = @student_2.id
        params[:course_id] = @course.id
        post :create, student_id: @student_2.id, student_academic_history: params
        expect(@student_2.student_academic_histories.where(course_id: @course.id).first.gpa).to eq(3)
      end

      it "does not increase the count with invalid attributes" do
        params = attributes_for(:student_academic_history, course_id: nil)
        expect{ post :create, student_academic_history: params, student_id: @student.id }.to_not change(StudentAcademicHistory,:count)
      end
    end

    describe "POST update" do
      it "updates an academic history with valid attributes" do
        params = attributes_for(:student_academic_history, gpa: 2.0)
        put :update, { student_id: @student.id, id: @academic_history.id, student_academic_history: params }
        expect(response).to redirect_to(student_path(@student))
        expect(@academic_history.reload.gpa.to_f).to eq(2.0)
      end

      it "does not update with invalid attributes" do
        params = { gpa: -1 }
        put :update, { student_id: @student.id, id: @academic_history.id, student_academic_history: params }
        expect(@academic_history.reload.gpa.to_f).to eq(2.2)
      end
    end

    describe "GET destroy" do
      it "destroys the academic history profile" do
        expect{ get :destroy, student_id: @student.id, id: @academic_history.id }.to change(StudentAcademicHistory,:count).by(-1)
        expect(response).to redirect_to(student_path(@student))
      end
    end

  end

  context "as a student" do
    before(:each) { login_user(@student) }

    describe "protected routes" do
      [
        :new,
        :create
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route, {student_id: @student.id}).to redirect_to(:root)
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
          expect(get route, {student_id: @student.id, id: 1}).to redirect_to(:root)
        end
      end
    end
  end
end
