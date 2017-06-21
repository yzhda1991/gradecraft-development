describe ChallengeGradesController do
  let(:course) { build :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:team) { create(:team, course: course) }
  let(:challenge) { create(:challenge, course: course) }
  let(:challenge_grade) { create(:challenge_grade, team: team, challenge: challenge) }

  context "as professor" do
    before(:each) do
      login_user(professor)
    end

    describe "GET show" do
      it "shows the challenge grade" do
        get :show, params: { id: challenge_grade }
        expect(response).to render_template(:show)
      end
    end

    describe "GET edit" do
      it "shows the edit challenge grade form" do
        get :edit, params: { id: challenge_grade, challenge_id: challenge,
                             team_id: team.id }
        expect(assigns(:challenge)).to eq(challenge)
        expect(assigns(:challenge_grade)).to eq(challenge_grade)
        expect(assigns(:team)).to eq(team)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST update" do
      it "updates the challenge grade" do
        params = attributes_for(:challenge_grade)
        params[:raw_points] = "100000"
        params[:challenge_id] = challenge.id
        params[:team_id] = team.id
        params[:complete] = true
        params[:student_visible] = true
        post :update, params: { id: challenge_grade.id, challenge_grade: params }
        expect(response).to redirect_to(challenge_path(challenge))
        expect(challenge_grade.reload.score).to eq(100000)
        expect(challenge_grade.instructor_modified).to be_truthy
        expect(team.reload.challenge_grade_score).to eq(100000)
      end

      it "redirects to edit form with invalid attributes" do
        params = { team_id: nil }
        post :update, params: { challenge_id: challenge.id, id: challenge_grade.id,
                                challenge_grade: params }
        expect(response).to render_template(:edit)
      end
    end

    describe "GET destroy" do
      it "destroys the challenge grade" do
        challenge_grade_2 = create(:challenge_grade, challenge: challenge)
        expect{ get :destroy, params: { id: challenge_grade_2,
                                        challenge_id: challenge.id }}.to \
          change(ChallengeGrade,:count).by(-1)
      end

      it "recalculates the team score" do
        challenge = create(:challenge, course: course)
        challenge_grade = create(:challenge_grade, challenge: challenge, team: team, raw_points: 100, student_visible: true)
        expect(team.challenge_grade_score).to eq(100)
        post :destroy, params: { id: challenge_grade, challenge_id: challenge.id }
        expect(team.reload.challenge_grade_score).to eq(0)
        expect(response).to redirect_to(challenge_path(challenge))
      end
    end
  end

  context "as student" do
    before(:each) do
      login_user(student)
    end

    describe "GET show" do
      it "shows the challenge grade" do
        get :show, params: { id: challenge_grade, challenge_id: challenge }
        expect(assigns(:challenge)).to eq(challenge)
        expect(assigns(:challenge_grade)).to eq(challenge_grade)
        expect(assigns(:team)).to eq(team)
        expect(response).to render_template(:show)
      end
    end

    describe "protected routes requiring id in params" do
      [
        :edit,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, params: { challenge_id: 2, id: "1" }).to redirect_to(:root)
        end
      end
    end
  end
end
