require 'spec_helper'

describe TasksController do
  before(:all) { @course = create(:course) }
  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as a professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
      @assignment = create(:assignment, course: @course)
    end
    before(:each) do
      @task = create(:task, assignment: @assignment)
      login_user(@professor)
    end

    describe "GET index" do
      it "redirects the tasks index to the assignment page" do
        get :index, :assignment_id => @assignment.id
        expect(response).to redirect_to(assignment_path(@assignment))
      end
    end
  end

  context "as a student" do
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
            expect(get route, {:assignment_id => 1}).to redirect_to(:root)
          end
        end
    end

    describe "protected routes with ids in the url" do
      [
        :show,
        :update,
        :destroy,
        :edit
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, {:assignment_id => 1, :id => "10"}).to redirect_to(:root)
        end
      end
    end
  end
end
