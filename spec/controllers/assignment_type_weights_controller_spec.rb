require 'spec_helper'

describe AssignmentTypeWeightsController do

  context "as professor" do

    before(:all) do
      @time = Time.now
      @course = create(:course,
                       total_assignment_weight: 6,
                       assignment_weight_close_at: @time,
                       max_assignment_weight: 2,
                       max_assignment_types_weighted: 4,
                       default_assignment_weight: 1
        )
      @assignment_type_weightable = create(:assignment_type, course: @course, student_weightable: true)
      @assignment_type_not_weightable = create(:assignment_type, course: @course, student_weightable: false)

      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @student = create(:user)
      @student.courses << @course
    end

    before do
      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

    describe "GET mass_edit" do
      it "assigns params" do
        get :mass_edit, :student_id => @student.id
        expect(assigns(:title)).to eq("Editing #{@student.name}'s multipliers")
        expect(response).to render_template(:mass_edit)
      end
    end

    describe "GET student predictor data" do

      it "returns weightable assignment type ids and all course info regarding weighting assignments" do
        get :predictor_data, format: :json, :id => @student.id
        expect(assigns(:assignment_types_weightable)).to eq([@assignment_type_weightable.id])
        expect(assigns(:total_weights)).to eq(@course.total_assignment_weight)
        expect(assigns(:close_at).to_s).to eq(@course.assignment_weight_close_at.to_s)
        expect(assigns(:max_weights)).to eq(@course.max_assignment_weight)
        expect(assigns(:max_types_weighted)).to eq(@course.max_assignment_types_weighted)
        expect(assigns(:default_weight)).to eq(@course.default_assignment_weight)
      end

      it "returns assignment types as json with current student if id present and no call to update" do
        get :predictor_data, format: :json, :id => @student.id
        expect(assigns(:student)).to eq(@student)
        expect(assigns(:update_weights)).to be_falsey
        expect(response).to render_template(:predictor_data)
      end

      it "returns assignment types with null student if no id present and no call to update" do
        get :predictor_data, format: :json
        expect(assigns(:student).class).to eq(NullStudent)
        expect(assigns(:update_weights)).to be_falsey
        expect(response).to render_template(:predictor_data)
      end
    end
  end

  context "as student" do

    before(:all) do
      @time = Time.now
      @course = create(:course,
                       total_assignment_weight: 6,
                       assignment_weight_close_at: @time,
                       max_assignment_weight: 2,
                       max_assignment_types_weighted: 4,
                       default_assignment_weight: 1
        )
      @assignment_type_weightable = create(:assignment_type, course: @course, student_weightable: true)
      @assignment_type_not_weightable = create(:assignment_type, course: @course, student_weightable: false)
      @student = create(:user)
      @student.courses << @course
    end

    before do
      allow(Resque).to receive(:enqueue).and_return(true)
      login_user(@student)
      session[:course_id] = @course.id
      allow(controller).to receive(:current_student).and_return(@student)
    end


    describe "GET mass_edit" do
      it "assigns params" do
        get :mass_edit, :student_id => @student.id
        expect(assigns(:title)).to eq("Editing My multiplier Choices")
        expect(response).to render_template(:mass_edit)
      end
    end

    describe "POST update" do

      before do
        # Won't work unless there is at least one assignment!
        # TODO: refactor weights on
        create(:assignment, assignment_type: @assignment_type_weightable, course: @course )
        create(:assignment, assignment_type: @assignment_type_not_weightable, course: @course )
      end

      it "updates assignment weights" do
        post :update, :id => @assignment_type_weightable.id, :weight => 2, :format => :json
        expect(@student.weight_for_assignment_type(@assignment_type_weightable)).to eq(2)
        expect(JSON.parse(response.body)).to eq({ "assignment_type" => @assignment_type_weightable.id, "weight" => 2 })
      end

      it "returns error message when assignment type is not weightable" do
        post :update, :id => @assignment_type_not_weightable.id, :weight => 2, :format => :json
        expect(@student.weight_for_assignment_type(@assignment_type_not_weightable)).to eq(0)
        expect(JSON.parse(response.body)).to eq({"errors"=>"Unable to update assignment type weight"})
      end
    end

    describe "GET student predictor data" do

      it "returns weightable assignment types info as json for the current course with a call to update" do
        get :predictor_data, format: :json
        expect(assigns(:student)).to eq(@student)
        expect(assigns(:assignment_types_weightable)).to eq([@assignment_type_weightable.id])
        expect(assigns(:total_weights)).to eq(@course.total_assignment_weight)
        expect(assigns(:close_at).to_s).to eq(@course.assignment_weight_close_at.to_s)
        expect(assigns(:max_weights)).to eq(@course.max_assignment_weight)
        expect(assigns(:max_types_weighted)).to eq(@course.max_assignment_types_weighted)
        expect(assigns(:default_weight)).to eq(@course.default_assignment_weight)
        expect(assigns(:update_weights)).to be_truthy
        expect(response).to render_template(:predictor_data)
      end
    end
  end
end
