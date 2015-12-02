require 'rails_spec_helper'

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

      context "with json format" do
        it "returns all courses in json format" do
          get :index, format: :json
          json = JSON.parse(response.body)
          expect(json.length).to eq Course.count
          expect(json[0].keys).to eq ["id", "name", "courseno",
                                      "year", "semester"]
        end
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

    describe "POST copy" do 
      it "creates a duplicate course" do 
        expect{ post :copy, :id => @course.id }.to change(Course, :count).by(1)
      end

      it "duplicates badges if present" do 
        create(:badge, course: @course)
        expect{ post :copy, :id => @course.id }.to change(Course, :count).by(1)
        course_2 = Course.last
        expect(course_2.badges.present?).to eq(true)
      end

      it "duplicates challenges if present" do 
        create(:challenge, course: @course)
        expect{ post :copy, :id => @course.id }.to change(Course, :count).by(1)
        course_2 = Course.last
        expect(course_2.challenges.present?).to eq(true)
      end

      it "duplicates grade_scheme_elements if present" do 
        create(:grade_scheme_element, course: @course)
        expect{ post :copy, :id => @course.id }.to change(Course, :count).by(1)
        course_2 = Course.last
        expect(course_2.grade_scheme_elements.present?).to eq(true)
      end

      it "duplicates assignment_types and assignments if present" do 
        assignment_type = create(:assignment_type, course: @course)
        create(:assignment, assignment_type: assignment_type, course: @course)
        expect{ post :copy, :id => @course.id }.to change(Course, :count).by(1)
        course_2 = Course.last
        expect(course_2.assignment_types.present?).to eq(true)
        expect(course_2.assignments.present?).to eq(true)
      end

      it "duplicates score levels if present" do         
        assignment_type = create(:assignment_type, course: @course)
        assignment = create(:assignment, assignment_type: assignment_type, course: @course)
        score_level = create(:assignment_score_level, assignment: assignment)
        expect{ post :copy, :id => @course.id }.to change(Course, :count).by(1)
        course_2 = Course.last
        assignment_2 = course_2.assignments.first
        expect(assignment_2.assignment_score_levels.present?).to eq(true)
      end

      it "duplicates rubrics if present" do 
        assignment_type = create(:assignment_type, course: @course)
        assignment = create(:assignment, assignment_type: assignment_type, course: @course)
        rubric = create(:rubric, assignment: assignment)
        metric = create(:metric, rubric: rubric)
        tier = create(:tier, metric: metric)
        expect{ post :copy, :id => @course.id }.to change(Course, :count).by(1)
        course_2 = Course.last
        expect(course_2.assignments.present?).to eq(true)
        assignment_2 = course_2.assignments.first
        rubric_2 = assignment_2.rubric
        metric_2 = rubric_2.metrics.first
        expect(assignment_2.rubric.present?).to eq(true)
        expect(rubric_2.metrics.present?).to eq(true)
        expect(metric_2.tiers.present?).to eq(true)
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
