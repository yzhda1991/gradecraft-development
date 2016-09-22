require "rails_spec_helper"

describe RubricsController do

  let(:course) { create :course }
  let(:professor) { create(:professor_course_membership, course: course).user }
  let(:student) { create(:student_course_membership, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let!(:rubric) { create(:rubric, assignment: assignment) }

  context "as a professor" do
    before do
      session[:course_id] = course.id
      allow(Resque).to receive(:enqueue).and_return(true)
      login_user(professor)
    end

    describe "GET design" do
      it "shows the design form" do
        get :design, { assignment_id: assignment.id, rubric: rubric}
        expect(assigns(:title)).to eq("Design Rubric for #{assignment.name}")
        expect(response).to render_template(:design)
      end
    end

    describe "GET export" do
      it "retrieves the export download" do
        get :export, assignment_id: assignment.id, format: :csv
        expect(response.body).to include("Criteria ID,Criteria Description")
      end
    end

    describe "GET copy" do
      let(:new_assignment) { create(:assignment, course: course) }

      it "retrieves the list of rubric for course to add" do
        get :copy, assignment_id: new_assignment.id
        expect(assigns(:assignment)).to eq(new_assignment)
        expect(assigns(:rubrics)).to eq([rubric])
      end
    end
  end

  context "as a student" do
    before { login_user(student) }

    describe "protected routes" do
      [
        :design,
        :create,
        :copy,
        :destroy,
        :update
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route, {assignment_id: 1, id: "1"}).to redirect_to(:root)
          end
        end
    end
  end
end
