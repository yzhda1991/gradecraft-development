describe AssignmentsController do
  let(:course) { build(:course) }
  let(:assignment_type) { create(:assignment_type, course: course) }
  let(:assignment) { create(:assignment, assignment_type: assignment_type, course: course) }

  context "as a professor" do
    let(:professor) { create(:user, courses: [course], role: :professor) }
    before(:each) { login_user(professor) }

    describe "GET index" do
      it "returns assignments for the current course" do
        get :index
        expect(assigns(:assignment_types)).to eq([assignment_type])
        expect(response).to render_template(:index)
      end
    end

    describe "GET settings" do
      it "returns title and assignments" do
        get :settings
        expect(assigns(:assignment_types)).to eq([assignment_type])
        expect(response).to render_template(:settings)
      end
    end

    describe "GET show" do
      it "returns the assignment show page" do
        get :show, params: { id: assignment.id }
        expect(response).to render_template(:show)
      end
    end

    describe "POST copy" do
      it "returns an error if there are validation errors" do
        allow_any_instance_of(Assignment).to receive(:copy_with_prepended_name).and_raise CopyValidationError, {}
        post :copy, params: { id: assignment.id }
        expect(response).to have_http_status :internal_server_error
      end

      it "duplicates an assignment" do
        post :copy, params: { id: assignment.id }
        expect expect(course.assignments.count).to eq(2)
      end

      it "duplicates score levels" do
        assignment.assignment_score_levels.create(name: "Level 1", points: 10_000)
        post :copy, params: { id: assignment.id }
        duplicated = Assignment.last
        expect(duplicated.id).to_not eq assignment.id
        expect(duplicated.assignment_score_levels.first.name).to eq "Level 1"
        expect(duplicated.assignment_score_levels.first.points).to eq 10_000
      end

      it "duplicates rubrics" do
        assignment.create_rubric(course: assignment.course)
        assignment.rubric.criteria.create name: "Rubric 1", max_points: 10_000, order: 1
        assignment.rubric.criteria.first.levels.first.badges.create! name: "Blah", course: course
        post :copy, params: { id: assignment.id }
        duplicated = Assignment.last
        expect(duplicated.rubric).to_not be_nil
        expect(duplicated.rubric.criteria.first.name).to eq "Rubric 1"
        expect(duplicated.rubric.criteria.first.levels.first.name).to eq "Full Credit"
      end

      it "redirects to the edit page for the duplicated assignment" do
        post :copy, params: { id: assignment.id }
        duplicated = Assignment.last
        expect(response).to redirect_to(edit_assignment_path(duplicated))
      end
    end

    describe "GET export_structure" do
      it "retrieves the export_structure download" do
        get :export_structure, params: { id: course.id }, format: :csv
        expect(response.body).to include("Assignment ID,Name,Point Total,Description,Open At,Due At,Accept Until")
      end
    end

    describe "GET destroy" do
      it "destroys the assignment" do
        assignment = create(:assignment, assignment_type: assignment_type, course: course)
        expect{ get :destroy, params: { id: assignment.id }}.to \
          change(Assignment,:count).by(-1)
      end
    end
  end

  context "as a student" do
    let(:student) { create(:user, courses: [course], role: :student) }
    before(:each) { login_user(student) }

    describe "GET index" do
      it "returns assignments for the current course" do
        get :index
        expect(response).to render_template(:index)
      end
    end

    describe "GET show" do
      it "marks the grade as reviewed" do
        grade = create(:grade, assignment: assignment, student: student, student_visible: true)
        get :show, params: { id: assignment.id }
        expect(grade.reload).to be_feedback_reviewed
      end

      it "redirects to the assignments path of the assignment does not exist for the current course" do
        another_assignment = create :assignment
        get :show, params: { id: another_assignment.id }
        expect(response).to redirect_to assignments_path
      end
    end

    describe "protected routes" do
      [
        :new,
        :copy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route).to redirect_to(:root)
        end
      end
    end

    describe "protected routes requiring id in params" do
      [
        :edit,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, params: { id: "1" }).to redirect_to(:root)
        end
      end
    end
  end

  context "as an observer" do
    let(:observer) { create(:user, courses: [course], role: :observer) }
    before(:each) { login_user(observer) }

    describe "GET index" do
      it "returns assignments for the current course" do
        expect(get :index).to render_template(:index)
      end
    end

    describe "GET show" do
      it "returns the assignment show page" do
        get :show, params: { id: assignment.id }
        expect(response).to render_template(:show)
      end
    end

    describe "protected routes not requiring id in params" do
      routes = [
        { action: :new, request_method: :get },
        { action: :settings, request_method: :get }
      ]
      routes.each do |route|
        it "#{route[:request_method]} :#{route[:action]} redirects to root" do
          expect(eval("#{route[:request_method]} :#{route[:action]}")).to redirect_to(:root)
        end
      end
    end

    describe "protected routes requiring id in params" do
      params = { id: "1" }
      routes = [
        { action: :edit, request_method: :get },
        { action: :destroy, request_method: :get }
      ]
      routes.each do |route|
        it "#{route[:request_method]} :#{route[:action]} redirects to root" do
          expect(eval("#{route[:request_method]} :#{route[:action]}, params: #{params}")).to \
            redirect_to(:root)
        end
      end
    end
  end
end

def predictor_assignment_attributes
  [
    :accepts_submissions,
    :accepts_submissions_until,
    :assignment_type_id,
    :description,
    :due_at,
    :grade_scope,
    :id,
    :name,
    :pass_fail,
    :full_points,
    :position,
    :required,
    :use_rubric,
    :visible,
    :visible_when_locked
  ]
end
