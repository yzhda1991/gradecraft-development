require "rails_spec_helper"

describe SubmissionsController do
  before(:all) do
    @course = create(:course)
    @student = create(:user)
    @student.courses << @course
    @assignment = create(:assignment, course: @course)
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
    before(:each) do
      @submission = create(:submission, assignment_id: @assignment.id, assignment_type: "Assignment", student_id: @student.id, course_id: @course.id)
      login_user(@professor)
    end

    describe "GET show" do
      it "returns the submission show page" do
        get :show, {:id => @submission.id, :assignment_id => @assignment.id}
        expect(assigns(:title)).to eq("#{@student.first_name}'s #{@assignment.name} Submission (#{@assignment.point_total} points)")
        expect(assigns(:submission)).to eq(@submission)
        expect(response).to render_template(:show)
      end
    end

    describe "GET new" do
      it "assigns title and assignment relation" do
        get :new, assignment_id: @assignment.id
        expect(assigns(:title)).to eq("Submit #{@assignment.name} (#{@assignment.point_total} points)")
        expect(assigns(:submission)).to be_a_new(Submission)
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "display the edit form" do
        get :edit, {:id => @submission.id, :assignment_id => @assignment.id}
        expect(assigns(:title)).to eq("Editing #{@submission.student.name}'s Submission")
        expect(assigns(:submission)).to eq(@submission)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST create" do
      it "creates the submission with valid attributes"  do
        params = attributes_for(:submission)
        params[:assignment_id] = @assignment.id
        expect{ post :create, :assignment_id => @assignment.id, :submission => params }.to change(Submission,:count).by(1)
      end
    end

    describe "POST update" do
      it "updates the submission successfully"  do
        params = attributes_for(:submission)
        params[:assignment_id] = @assignment.id
        params[:text_comment] = "Ausgezeichnet"
        post :update, :assignment_id => @assignment.id, :id => @submission, :submission => params
        expect(response).to redirect_to(assignment_submission_path(@assignment, @submission))
        expect(@submission.reload.text_comment).to eq("Ausgezeichnet")
      end
    end

    describe "GET destroy" do
      it "destroys the submission" do
        expect{ get :destroy, {:id => @submission, :assignment_id => @assignment.id } }.to change(Submission,:count).by(-1)
      end
    end
  end

  context "as a student" do
    before do
      @submission = create(:submission, assignment_id: @assignment.id, assignment_type: "Assignment", student_id: @student.id, course_id: @course.id)
      login_user(@student)
    end

    describe "GET new" do
      it "assigns a new submission as @submission" do
        get :new, :assignment_id => @assignment.id
        expect(assigns(:submission)).to be_a_new(Submission)
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "shows the edit submission form" do
        get :edit, {:id => @submission.id, :assignment_id => @assignment.id}
        expect(assigns(:title)).to eq("Editing My Submission for #{@assignment.name}")
        expect(assigns(:submission)).to eq(@submission)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST create" do
      it "creates the submission with valid attributes"  do
        skip "implement"
        params = attributes_for(:submission)
        params[:assignment_id] = @assignment.id
        allow(SubmissionsController).to receive(:student).and_return(@student)
        expect{ post :create, :assignment_id => @assignment.id, :submission => params }.to change(Submission,:count).by(1)
      end
    end

    describe "GET update" do
      it "updates the submission successfully"  do
        params = attributes_for(:submission)
        params[:assignment_id] = @assignment.id
        params[:text_comment] = "Ausgezeichnet"
        post :update, :assignment_id => @assignment.id, :id => @submission, :submission => params
        expect(response).to redirect_to(assignment_path(@assignment, :anchor => "fndtn-tabt3"))
        expect(@submission.reload.text_comment).to eq("Ausgezeichnet")
      end
    end

    describe "protected routes requiring id in params" do
      [
        :show,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, {:assignment_id => 1, :id => "1"}).to redirect_to(:root)
        end
      end
    end
  end
end
