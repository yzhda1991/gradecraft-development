describe API::CriterionGradesController do
  let(:course) { create :course }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:assignment) { create :assignment, course: course }
  let(:grade) { create(:grade, student: student, assignment: assignment, course: course) }
  let!(:rubric) { create(:rubric, assignment: assignment) }
  let!(:criterion) { create(:criterion, rubric: rubric) }
  let(:level) { create(:level, criterion: criterion) }
  let(:criterion_grade) { create(:criterion_grade, assignment: assignment, level: level, student: student, criterion: criterion) }
  let(:badge) { create(:badge, course: course) }
  let(:group) { create :group }

  let(:professor) { create(:course_membership, :professor, course: course).user }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "GET index" do
      it "returns a student's criterion grades for the current assignment" do
        get :index,
          params: { assignment_id: assignment.id, student_id: student.id },
          format: :json
        expect(assigns(:criterion_grades)).to eq([criterion_grade])
        expect(response).to render_template(:index)
      end
    end

    describe "GET group_index" do
      before(:each) do
        group.students.each do |student|
          create :criterion_grade, assignment_id: assignment.id, student_id: student.id
        end
      end

      it "returns 400 error code with individual assignment" do
        assignment.update_attributes grade_scope: "Individual"
        get :group_index,
          params: { assignment_id: assignment.id, group_id: group.id },
          format: :json
        expect(response.status).to be(400)
      end

      it "returns criterion_grades and student ids for a group" do
        assignment.update_attributes grade_scope: "Group"
        get :group_index,
          params: { assignment_id: assignment.id, group_id: group.id },
          format: :json
        expect(assigns(:student_ids)).to match_array group.students.pluck(:id)
        expect(assigns(:criterion_grades).length).to eq(group.students.length)
        expect(response).to render_template(:group_index)
      end
    end

    describe "PUT update" do
      let(:params) do
        RubricGradePUT.new(assignment, [criterion]).params.merge(assignment_id: assignment.id, student_id: student.id)
      end

      describe "finds or creates the grade for the assignment and student" do
        it "finds and updates existing grades" do
          create(:grade, assignment: assignment, student: student)
          expect { put :update, params: params, format: :json }.to change { Grade.count }.by(0)
        end

        it "assigns the grade to the submission" do
          submission = create :submission, assignment: assignment, student: student
          put :update, params: params, format: :json
          grade = Grade.unscoped.last
          expect(grade.submission).to eq submission
        end

        it "timestamps the grade" do
          current_time = DateTime.now
          put :update, params: params, format: :json
          grade = Grade.unscoped.last
          expect(grade.graded_at).to be > current_time
        end
      end

      describe "when an additional `criterion_ids` parameter is supplied" do
        before do
          params[:criterion_ids] = rubric.criteria.collect(&:id)
        end

        it "does not create new when criterion grades exist" do
          criterion_grade
          expect { put :update, params: params, format: :json }.to change { CriterionGrade.count }.by(0)
        end
      end

      it "adds earned level badges" do
        LevelBadge.create(level_id: criterion.levels.first.id, badge_id: badge.id)
        badge.update(can_earn_multiple_times: false)
        expect { put :update, params: params, format: :json }.to change { EarnedBadge.count }.by(1)
      end

      it "doesn't re-award existing level badges" do
        LevelBadge.create(level_id: criterion.levels.first.id, badge_id: badge.id)
        expect { put :update, params: params, format: :json }.to change { EarnedBadge.count }.by(1)
        expect { put :update, params: params, format: :json }.to change { EarnedBadge.count }.by(0)
      end

      it "renders success message when request format is JSON" do
        put :update, params: params, format: :json
        expect(response).to render_template("api/grades/show")
      end

      describe "on error" do
        it "describes unfound student or assignment" do
          params["student_id"] = 0
          put :update, params: params, format: :json
          expect(JSON.parse(response.body)).to eq("errors"=>[{"detail"=>"Unable to verify both student and assignment"}], "success"=>false)
          expect(response.status).to eq(404)
        end
      end
    end
  end

  context "as student" do
    before(:each) { login_user(student) }

    it "redirects protected routes to root" do
      [
        -> { get :index,
             params: { assignment_id: assignment.id, student_id: student.id },
             format: :json },
        -> { get :group_index, params: { assignment_id: assignment.id, group_id: 1 },
             format: :json },
        -> { put :update,
             params: RubricGradePUT.new(assignment, [criterion]).params
              .merge(assignment_id: assignment.id, student_id: student.id) }
      ].each do |protected_route|
        expect(protected_route.call).to redirect_to(:root)
      end
    end
  end
end
