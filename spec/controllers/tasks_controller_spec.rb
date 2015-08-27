#spec/controllers/tasks_controller_spec.rb
require 'spec_helper'

describe TasksController do

  #not yet built

  context "as a professor" do

    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @assignment_type = create(:assignment_type, course: @course)
      @assignment = create(:assignment, course: @course, assignment_type: @assignment_type)
      @task = create(:task)
      @assignment.tasks << @task
      @student = create(:user)
      @student.courses << @course
      @team = create(:team, course: @course)
      @team.students << @student
      @teams = @course.teams

      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

    describe "GET index" do
      it "redirects the tasks index to the assignment page" do
        get :index, :assignment_id => @assignment.id
        expect(response).to redirect_to(assignment_path(@assignment))
      end
    end

  end

  context "as a student" do
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
