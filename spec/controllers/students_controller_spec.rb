require "rails_spec_helper"

describe StudentsController do
  before(:all) do
    @course = create(:course)
    @student = create(:user, courses: [@course], role: :student)
  end
  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as a professor" do
    before(:all) do
      @professor = create(:user, courses: [@course], role: :professor)
    end
    before(:each) { login_user(@professor) }

    describe "GET index" do
      it "returns the students for the current course" do
        get :index
        expect(response).to render_template(:index)
      end
    end

    describe "GET show" do
      it "shows the student page" do
        get :show, params: { id: @student.id }
        expect(response).to render_template(:show)
      end
    end

    describe "GET grade_index" do
      it "shows the grade index page" do
        get :grade_index, params: { id: @student.id }
        allow(StudentsController).to \
          receive(:current_student).and_return(@student)
        expect(response).to render_template(:grade_index)
      end
    end

    describe "GET recalculate" do
      it "triggers the recalculation of a student's grade" do
        get :recalculate, params: { id: @student.id }
        expect(response).to redirect_to(student_path(@student))
      end
    end
  end

  context "as a student" do
    before { login_user(@student) }

    describe "protected routes" do
      [
        :index,
        :autocomplete_student_name,
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route).to redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :show,
        :grade_index,
        :recalculate
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, params: { id: "10" }).to redirect_to(:root)
        end
      end
    end
  end
end
