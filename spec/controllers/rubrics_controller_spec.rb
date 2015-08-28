require 'spec_helper'

describe RubricsController do
	context "as a professor" do
    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @assignment = create(:assignment)
      @course.assignments << @assignment
      @rubric = create(:rubric, assignment: @assignment)

      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

    describe "GET design" do
      it "shows the design form" do
        skip "implement"
        get :design, { assignment_id: @assignment.id, rubric: @rubric}
        expect(assigns(:title)).to eq("Create a New assignment Type")
        expect(assigns(:assignment_type)).to be_a_new(AssignmentType)
        expect(response).to render_template(:design)
      end
    end
	end

	context "as a student" do
		describe "protected routes" do
      [
        :design,
        :create,
        :destroy,
        :update,
        :existing_metrics,
        :course_badges
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route, {:assignment_id => 1, :id => "1"}).to redirect_to(:root)
          end
        end
    end

	end
end
